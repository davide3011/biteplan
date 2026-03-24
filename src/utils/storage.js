export const save = (key, val) => localStorage.setItem(key, JSON.stringify(val))
export const load = (key, def) => {
  const v = localStorage.getItem(key)
  return v ? JSON.parse(v) : def
}
