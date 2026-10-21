-- Добавляет 5 новых ключей интерфейса (кнопка "Sign Out and Delete All Data"
-- на экране профиля) в словарь app_translation для всех 6 языков.
-- Безопасно перезапускать — при повторном запуске просто обновит value.

BEGIN;

INSERT INTO app_translation (language_code, key, value) VALUES
  ('en', 'profile.deleteAllData', 'Sign Out and Delete All Data'),
  ('en', 'profile.deleteAllDataConfirmTitle', 'Delete all data?'),
  ('en', 'profile.deleteAllDataConfirmMessage', 'This permanently deletes your account and everything in it — profile, meal plans, recipes, lab reports and photos. This cannot be undone.'),
  ('en', 'profile.deleteAllDataConfirm', 'Delete Everything'),
  ('en', 'profile.deleteAllDataFailed', 'Couldn''t delete your account. Please check your connection and try again.'),

  ('ru', 'profile.deleteAllData', 'Выйти и удалить все данные'),
  ('ru', 'profile.deleteAllDataConfirmTitle', 'Удалить все данные?'),
  ('ru', 'profile.deleteAllDataConfirmMessage', 'Это навсегда удалит ваш аккаунт и всё, что в нём — профиль, планы питания, рецепты, отчёты анализов и фото. Это действие нельзя отменить.'),
  ('ru', 'profile.deleteAllDataConfirm', 'Удалить всё'),
  ('ru', 'profile.deleteAllDataFailed', 'Не удалось удалить аккаунт. Проверьте подключение и попробуйте снова.'),

  ('pl', 'profile.deleteAllData', 'Wyloguj się i usuń wszystkie dane'),
  ('pl', 'profile.deleteAllDataConfirmTitle', 'Usunąć wszystkie dane?'),
  ('pl', 'profile.deleteAllDataConfirmMessage', 'To nieodwracalnie usunie twoje konto i wszystko w nim — profil, plany posiłków, przepisy, raporty badań i zdjęcia. Tej operacji nie można odwrócić.'),
  ('pl', 'profile.deleteAllDataConfirm', 'Usuń wszystko'),
  ('pl', 'profile.deleteAllDataFailed', 'Nie udało się usunąć konta. Sprawdź połączenie i spróbuj ponownie.'),

  ('de', 'profile.deleteAllData', 'Abmelden und alle Daten löschen'),
  ('de', 'profile.deleteAllDataConfirmTitle', 'Alle Daten löschen?'),
  ('de', 'profile.deleteAllDataConfirmMessage', 'Dadurch werden dein Konto und alles darin dauerhaft gelöscht — Profil, Essenspläne, Rezepte, Laborberichte und Fotos. Dies kann nicht rückgängig gemacht werden.'),
  ('de', 'profile.deleteAllDataConfirm', 'Alles löschen'),
  ('de', 'profile.deleteAllDataFailed', 'Konto konnte nicht gelöscht werden. Bitte überprüfe deine Verbindung und versuche es erneut.'),

  ('es', 'profile.deleteAllData', 'Cerrar sesión y eliminar todos los datos'),
  ('es', 'profile.deleteAllDataConfirmTitle', '¿Eliminar todos los datos?'),
  ('es', 'profile.deleteAllDataConfirmMessage', 'Esto eliminará permanentemente tu cuenta y todo lo que contiene: perfil, planes de comidas, recetas, informes de laboratorio y fotos. Esta acción no se puede deshacer.'),
  ('es', 'profile.deleteAllDataConfirm', 'Eliminar todo'),
  ('es', 'profile.deleteAllDataFailed', 'No se pudo eliminar la cuenta. Comprueba tu conexión e inténtalo de nuevo.'),

  ('pt', 'profile.deleteAllData', 'Sair e excluir todos os dados'),
  ('pt', 'profile.deleteAllDataConfirmTitle', 'Excluir todos os dados?'),
  ('pt', 'profile.deleteAllDataConfirmMessage', 'Isso excluirá permanentemente sua conta e tudo o que há nela — perfil, planos de refeições, receitas, laudos de exames e fotos. Essa ação não pode ser desfeita.'),
  ('pt', 'profile.deleteAllDataConfirm', 'Excluir tudo'),
  ('pt', 'profile.deleteAllDataFailed', 'Não foi possível excluir a conta. Verifique sua conexão e tente novamente.')

ON CONFLICT (language_code, key) DO UPDATE
  SET value = EXCLUDED.value,
      utime = now();

COMMIT;
