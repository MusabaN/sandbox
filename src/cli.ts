import { version } from "../package.json" with { type: "json" };

function main(argv: string[]): number {
  if (argv.includes("--version")) {
    console.log(`sandbox ${version}`);
    return 0;
  }

  return 1;
}

process.exit(main(process.argv.slice(2)));
