import PgObject from 'pgobject';

export default class LabReportModel extends PgObject {
  static get schema() {
    return {
      id: {
        pk: true
      },
      user_id: {
        required: true
      },
      file_url: {},
      lab_name: {},
      taken_at: {},
      status: {
        default: 'processing'
      },
      error_message: {},
      raw_response: {},
      ctime: {
        default: new Date()
      }
    }
  }

  static get table() {
    return 'lab_report';
  }

  static async getById(id) {
    const rows = await LabReportModel.select('WHERE id = $1 LIMIT 1', [id]);
    return rows[0];
  }

  static async getByUserId(userId) {
    return LabReportModel.select('WHERE user_id = $1 ORDER BY COALESCE(taken_at, ctime::date) DESC, ctime DESC', [userId]);
  }
}
