const PgBossModule = require("pg-boss");
const PgBoss = PgBossModule.default || PgBossModule.PgBoss || PgBossModule;

let boss;

function getBoss() {
  if (!boss) {
    if (!process.env.DATABASE_URL) {
      throw new Error("DATABASE_URL is required for the job queue.");
    }
    boss = new PgBoss({ connectionString: process.env.DATABASE_URL });
  }
  return boss;
}

async function enqueue(name, data, options) {
  const queue = getBoss();
  await queue.start();
  return queue.send(name, data, options);
}

async function processJob(name, handler) {
  const queue = getBoss();
  await queue.start();
  return queue.work(name, handler);
}

async function shutdownQueue() {
  if (boss) {
    await boss.stop();
    boss = undefined;
  }
}

module.exports = { enqueue, processJob, shutdownQueue };
