const _shoco = require("./_shoco");

var _shoco_compress = _shoco['cwrap']('shoco_compress', 'number', ['string', 'number', 'number', 'number']);
var _shoco_decompress = _shoco['cwrap']('shoco_decompress', 'number', ['number', 'number', 'number', 'number']);

exports.compress = function(str_in) {
  var out_heap = _shoco['_malloc'](str_in.length * 8);
  var out_buffer = new Uint8Array(_shoco['HEAPU8']['buffer'], out_heap, str_in.length * 8);

  var len = _shoco_compress(str_in, 0, out_buffer.byteOffset, out_buffer.byteLength);
  var result = new Uint8Array(out_buffer.subarray(0, len));

  _shoco['_free'](out_buffer.byteOffset);
  return result;
}

exports.decompress = function(cmp) {
  var out_heap = _shoco['_malloc'](cmp.length * 8);
  var out_buffer = new Uint8Array(_shoco['HEAPU8']['buffer'], out_heap, cmp.length * 8);

  var in_heap = _shoco['_malloc'](cmp.length);
  var in_buffer = new Uint8Array(_shoco['HEAPU8']['buffer'], in_heap, cmp.length);
  in_buffer.set(new Uint8Array(cmp.buffer));

  var len = _shoco_decompress(in_buffer.byteOffset, cmp.length, out_buffer.byteOffset, out_buffer.byteLength);
  var result = decodeURIComponent(escape(String.fromCharCode.apply(null, out_buffer.subarray(0, len))));

  _shoco['_free'](in_buffer.byteOffset);
  _shoco['_free'](out_buffer.byteOffset);
  return result;
}
