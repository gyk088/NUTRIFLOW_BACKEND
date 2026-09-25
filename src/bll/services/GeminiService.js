import { GoogleGenAI, Type } from '@google/genai';

let client;

// Ленивая инициализация — process.env.GEMINI_API_KEY читается при первом
// реальном вызове, а не при импорте модуля (см. src/env.js: импорты роутов
// в src/index.js статически подтягивают модели/сервисы ДО dotenv.config()).
function getClient() {
  if (!client) {
    if (!process.env.GEMINI_API_KEY) throw new Error('Gemini is not configured on the server');
    client = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
  }
  return client;
}

const RESULT_SCHEMA = {
  type: Type.OBJECT,
  properties: {
    lab_name: { type: Type.STRING, nullable: true, description: 'Название лаборатории/клиники, если указано в отчёте' },
    taken_at: {
      type: Type.STRING,
      nullable: true,
      description: 'Дата взятия пробы либо дата выдачи результата, в формате YYYY-MM-DD. null, если дату определить нельзя'
    },
    results: {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          name: { type: Type.STRING, description: 'Название показателя ровно как напечатано в отчёте' },
          value: { type: Type.STRING, description: 'Значение ровно как напечатано, включая любые пометки/качественные результаты' },
          value_numeric: { type: Type.NUMBER, nullable: true, description: 'Числовое значение, если value — обычное число, иначе null' },
          unit: { type: Type.STRING, nullable: true, description: 'Единица измерения' },
          ref_range: { type: Type.STRING, nullable: true, description: 'Референсные значения ровно как напечатаны в отчёте' },
          ref_min: { type: Type.NUMBER, nullable: true, description: 'Нижняя граница нормы, если референс — числовой диапазон' },
          ref_max: { type: Type.NUMBER, nullable: true, description: 'Верхняя граница нормы, если референс — числовой диапазон' },
          flag: { type: Type.STRING, nullable: true, description: 'low | normal | high — только если определимо из отчёта (стрелка, звёздочка, явная пометка)' },
          description: { type: Type.STRING, description: 'Простыми словами, без медицинских терминов: что это за показатель и зачем он организму' },
          low_effects: { type: Type.STRING, description: 'Простыми словами: что может происходить и как человек может себя чувствовать при пониженном значении / нехватке' },
          high_effects: { type: Type.STRING, description: 'Простыми словами: что может происходить и как человек может себя чувствовать при повышенном значении / избытке' },
          food_sources: {
            type: Type.ARRAY,
            items: { type: Type.STRING },
            description: 'Продукты питания, богатые этим витамином/микроэлементом/нутриентом. Пустой массив, если показатель не связан с питанием'
          }
        },
        required: ['name', 'value', 'description', 'low_effects', 'high_effects', 'food_sources']
      }
    }
  },
  required: ['results']
};

function buildPrompt(languageName) {
  return `Ты разбираешь результаты медицинского лабораторного анализа из приложенного файла (PDF или фото бланка).

1. Извлеки название лаборатории, дату анализа и КАЖДЫЙ показатель со значением, единицей измерения, референсным диапазоном и отклонением от нормы, если оно явно отмечено в документе.
   Извлекай эти данные ровно так, как они напечатаны — не переводи, не округляй, не придумывай единицы или референсы, которых нет в документе. Если поле нельзя определить — верни null, а не догадку.

2. Для КАЖДОГО показателя дополнительно напиши справочную информацию на языке: ${languageName}.
   Пиши для человека без медицинского образования, простыми словами, как объяснял бы друг-врач за чашкой чая:
   - короткие предложения, обычные бытовые слова; медицинские термины и латынь не используй. Если без термина не обойтись (например, «анемия») — сразу объясни его в скобках простыми словами;
   - не используй сокращения и аббревиатуры без расшифровки;
   - по возможности помогай понять на образах (например: «гемоглобин — это как маленькие грузовики, которые развозят кислород по всему телу»);
   - говори о том, что человек может почувствовать сам (усталость, сонливость, жажда, выпадение волос), а не о механизмах в организме.
   Поля:
   - description — 1–2 предложения: что это за показатель и зачем он организму;
   - low_effects — что может происходить и как человек может себя чувствовать, если значение ниже нормы или этого вещества не хватает;
   - high_effects — что может происходить и как человек может себя чувствовать, если значение выше нормы или этого вещества слишком много;
   - food_sources — список обычных продуктов, в которых содержится этот витамин, микроэлемент или нутриент (называй знакомые продукты, а не категории). Если показатель не связан с питанием (например, лейкоциты, СОЭ) — пустой массив.
   Это общая справочная информация, а не диагноз: не ставь диагнозов, не назначай лечение и дозировки, не пугай — тон спокойный и поддерживающий. Каждое поле — не длиннее 2–3 предложений.`;
}

export default class GeminiService {
  static async parseLabReport(buffer, mimeType, languageName = 'русский') {
    const ai = getClient();
    const model = process.env.GEMINI_MODEL || 'gemini-flash-latest';

    const response = await ai.models.generateContent({
      model,
      contents: [
        {
          role: 'user',
          parts: [{ text: buildPrompt(languageName) }, { inlineData: { mimeType, data: buffer.toString('base64') } }]
        }
      ],
      config: {
        responseMimeType: 'application/json',
        responseSchema: RESULT_SCHEMA
      }
    });

    const text = response.text;
    console.log('Gemini response text:', text);
    if (!text) throw new Error('Gemini returned an empty response');

    try {
      return JSON.parse(text);
    } catch {
      throw new Error('Gemini returned invalid JSON');
    }
  }
}
