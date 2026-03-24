export const rawToCooked = (food, method, raw, db) => raw * db[food][method].yield
export const cookedToRaw = (food, method, cooked, db) => cooked / db[food][method].yield
