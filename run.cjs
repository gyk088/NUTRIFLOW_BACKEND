const util = require('util');
const exec = util.promisify(require('child_process').exec);

// Замените __APP_NAME__ на имя нового приложения (pm2 process name)
const step1 = "pm2 start npm --name nutriflow-backend -- run start"

async function run() {
    try {
        const { stdout, stderr } = await exec(step1);
        console.log('stdout:', stdout);
        console.log('stderr:', stderr);
    } catch (e) {
        console.error(e);
    }
}

run()
