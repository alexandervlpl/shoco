const shoco = require("./shoco");

const util = require("util");
let encoder = new util.TextEncoder();

var input = process.argv[2];
var comp = shoco.compress(process.argv[2]);
var result = shoco.decompress(comp);
console.log(encoder.encode(input).length + " > " + comp.length);
console.log(result);
