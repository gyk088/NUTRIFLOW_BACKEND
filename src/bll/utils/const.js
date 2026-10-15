export const ROLES = {
    SUPER_ADMIN: 'super_admin',
    ADMIN: 'admin',
    USER: 'user'
}

// super_admin имеет все права admin, плюс управление ролями пользователей
// (см. UserService.setRole) — используйте этот список в auth([...]) везде,
// где сейчас достаточно обычного admin.
export const ADMIN_AND_ABOVE = [ROLES.SUPER_ADMIN, ROLES.ADMIN]

// Единицы измерения ингредиента/состава рецепта. Весовые/объёмные переводятся в
// граммы прямым коэффициентом (мл считаем как г), остальные — через
// ingredient.grams_per_unit (см. RecipeService.toGrams).
export const UNIT_TO_GRAMS = { g: 1, kg: 1000, ml: 1, l: 1000 };
export const MEASURE_UNITS = [...Object.keys(UNIT_TO_GRAMS), 'piece', 'tbsp', 'tsp', 'cup', 'slice', 'clove'];

// Имена справочников — совпадают со значениями name в таблице dictionary_update
// (см. install/steps/3.sql) и используются сервисами, чтобы отмечать время
// последнего изменения каталога.
export const DICTIONARIES = {
    INGREDIENT: 'ingredient',
    RECIPE: 'recipe',
    TAG: 'tag'
}

export default {
    ROLES,
    ADMIN_AND_ABOVE,
    UNIT_TO_GRAMS,
    MEASURE_UNITS,
    DICTIONARIES
}
