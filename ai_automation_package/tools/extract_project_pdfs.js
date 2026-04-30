const fs = require("fs");
const path = require("path");
const { PDFParse } = require("./pdf_node/node_modules/pdf-parse");

const files = [
  ["CM PJT_1", "[삼우씨엠] 위례신도시 복정역세권 복합개발사업 건설사업관리(책임감리) 용역 기술제안서.pdf"],
  ["CM PJT_1", "복정역세권 RFP.pdf"],
  ["CM PJT_2", "[제안서] KB 국민은행 여의도 본관 재건축 건설사업관리(CM) 용역_삼우씨엠건축사사무소.pdf"],
  ["CM PJT_2", "KB국민은행 여의도 본관 재건축 건설사업관리용역_과업지시서.pdf"],
  ["CM PJT_2", "KB국민은행 여의도 본관 재건축 건설사업관리용역_평가 및 업체 선정 기준.pdf"],
  ["CM PJT_2", "입찰공고(KB국민은행_여의도_본관_재건축_건설사업관리용역)_6294315917924821.pdf"],
  ["CM PJT_2", "제안요청서_(여의도_본관_재건축_건설사업관리용역).pdf"],
  ["CM PJT_3", "1. 입찰공고문(CM선정).pdf"],
  ["CM PJT_3", "2. 제안요청서(CM선정).pdf"],
  ["CM PJT_3", "학교법인 연세대학교 동문회관 부지 개발 프로젝트 건설사업관리 용역 종합기술제안서.pdf"],
];

function safeName(value) {
  return value
    .replace(/[\\/:*?"<>|\[\]()\s]+/g, "_")
    .replace(/_+/g, "_")
    .replace(/^_|_$/g, "");
}

async function main() {
  const outDir = path.join("ai_automation_package", "analysis_extracts");
  fs.mkdirSync(outDir, { recursive: true });

  for (const [dir, name] of files) {
    const file = path.join(dir, name);
    const parser = new PDFParse({ data: fs.readFileSync(file) });
    const info = await parser.getInfo({ parsePageInfo: false });
    const data = await parser.getText();
    await parser.destroy();
    const out = path.join(outDir, `${safeName(`${dir}__${name}`)}.txt`);
    const header = [
      `SOURCE: ${file}`,
      `PAGES: ${info.total}`,
      `TEXT_LENGTH: ${data.text.length}`,
      "",
    ].join("\n");

    fs.writeFileSync(out, `${header}${data.text}`, "utf8");
    console.log(`${file}\tpages=${info.total}\tchars=${data.text.length}\t-> ${out}`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
