import { beforeEach, afterEach } from 'vitest'

// Svuota localStorage prima e dopo ogni test per garantire isolamento
beforeEach(() => localStorage.clear())
afterEach(() => localStorage.clear())
