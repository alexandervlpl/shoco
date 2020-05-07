const shoco = require("./shoco");
var result = shoco.decompress(shoco.compress("hello world"));
console.log(result);
