import UserService from '../bll/services/UserService.js';

export default class UserController {
    static async getMe(request, reply) {
        try {
            const user = await UserService.getById(request.user.f.id);
            return user;
        } catch (error) {
            reply.code(404).send({ error: error.message });
        }
    }

    static async updateMe(request, reply) {
        try {
            const user = await UserService.updateProfile(request.user.f.id, request.body);
            return user;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }
}
