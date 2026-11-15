export function getRandomPassword() {
    return Math.random().toString(36).slice(-8);
}

export function getRandomInt(min, max) {
  return parseInt(Math.random() * (max - min) + min);
}

export function validateEmail(email) {
  const re = /^([a-z0-9_-]+\.)*[+a-z0-9_-]+@[a-z0-9_-]+(\.[a-z0-9_-]+)*\.[a-z]{2,6}$/
  return re.test(String(email).toLowerCase())
}

export function fileExt(name) {
  const m = name.match(/\.([^.]+)$/)
  return m && m[1]
}

export function cutStr(str, n) {
  return str && str.length > n ? str.slice(0, n) + '...' : str
}

// Группирует массив в Map<ключ, элементы[]>, сохраняя исходный порядок —
// для пакетной сборки списков (одним запросом на таблицу вместо запросов на
// каждую запись).
export function groupBy(items, keyOf) {
  const map = new Map();
  for (const item of items) {
    const key = keyOf(item);
    const list = map.get(key);
    if (list) list.push(item);
    else map.set(key, [item]);
  }
  return map;
}
