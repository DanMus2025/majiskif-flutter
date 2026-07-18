const fs = require("fs");
const path = require("path");
const { chromium } = require("playwright");

const root = path.resolve(__dirname);
const html = path.join(root, "promo_kese.html");
const outDir = root;
const finalPath = path.join(outDir, "KESE-publicite.webm");

(async () => {
  const browser = await chromium.launch({
    headless: true,
    executablePath: "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
    args: ["--autoplay-policy=no-user-gesture-required"],
  });
  const context = await browser.newContext({
    viewport: { width: 1920, height: 1080 },
    recordVideo: {
      dir: outDir,
      size: { width: 1920, height: 1080 },
    },
  });
  const page = await context.newPage();
  await page.goto(`file:///${html.replace(/\\/g, "/")}`);
  await page.waitForTimeout(66000);
  const video = page.video();
  await context.close();
  await browser.close();
  const videoPath = await video.path();
  if (fs.existsSync(finalPath)) fs.unlinkSync(finalPath);
  fs.renameSync(videoPath, finalPath);
  const size = fs.statSync(finalPath).size;
  if (size < 1024) throw new Error(`Video recording is empty (${size} bytes)`);
  console.log(finalPath);
})();
