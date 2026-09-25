import PgObject from 'pgobject';

export default class LabResultModel extends PgObject {
  static get schema() {
    return {
      id: {
        pk: true
      },
      report_id: {
        required: true
      },
      name: {
        required: true
      },
      value: {
        required: true
      },
      value_numeric: {},
      unit: {},
      ref_range: {},
      ref_min: {},
      ref_max: {},
      flag: {},
      description: {},
      low_effects: {},
      high_effects: {},
      food_sources: {}
    }
  }

  static get table() {
    return 'lab_result';
  }

  static async getByReportId(reportId) {
    return LabResultModel.select('WHERE report_id = $1', [reportId]);
  }

  static async deleteByReportId(reportId) {
    return LabResultModel.query('DELETE FROM lab_result WHERE report_id = $1', [reportId]);
  }

  // История значений одного показателя по всем отчётам пользователя — для
  // графика на клиенте. JOIN за пределами своей таблицы (нужна дата отчёта),
  // поэтому без classObj — обычный select() всегда делает `SELECT * FROM
  // lab_result`, а строгая схема pgobject не пропустит "чужую" колонку r.taken_at.
  static async getHistoryForUser(userId, name) {
    const result = await LabResultModel.query(
      `SELECT lr.value, lr.value_numeric, lr.unit, lr.ref_min, lr.ref_max, lr.flag,
              COALESCE(r.taken_at, r.ctime::date) AS taken_at
       FROM lab_result lr
       JOIN lab_report r ON r.id = lr.report_id
       WHERE r.user_id = $1 AND r.status = 'done' AND lr.name ILIKE $2
       ORDER BY taken_at`,
      [userId, name]
    );
    return result.rows;
  }
}
