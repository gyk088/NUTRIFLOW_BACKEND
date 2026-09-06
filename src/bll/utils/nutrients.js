// Список нутриентных колонок ingredient (см. install/steps/2.sql) — общий
// для схемы IngredientModel и для расчёта КБЖУ рецепта в RecipeService.
export const MACRO_FIELDS = [
  'calories', 'protein', 'carbs', 'fat', 'fiber', 'sugar', 'saturated_fat',
  'cholesterol', 'sodium', 'omega_3', 'omega_6'
];

export const VITAMIN_FIELDS = [
  'vitamin_a', 'vitamin_b1', 'vitamin_b2', 'vitamin_b3', 'vitamin_b5', 'vitamin_b6',
  'vitamin_b7', 'vitamin_b9', 'vitamin_b12', 'vitamin_c', 'vitamin_d', 'vitamin_e', 'vitamin_k'
];

export const MINERAL_FIELDS = [
  'calcium', 'iron', 'magnesium', 'phosphorus', 'potassium', 'zinc', 'copper',
  'manganese', 'selenium', 'iodine'
];

export const NUTRIENT_FIELDS = [...MACRO_FIELDS, ...VITAMIN_FIELDS, ...MINERAL_FIELDS];
