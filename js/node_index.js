
location = {pathname:process.argv[1]};

var arguments = process.argv.slice(2);
for (var i = 0; i < arguments.length; i++) {
  console.log(i + ': ' + arguments[i]);
}

var samples = [
  "node_hello.js",
  "node_transpose.js",
  "node_trajectories.js",
  "node_scan.js",
  "node_reduce.js",
  "node_noise.js",
  "node_qjulia.js",
];

if (arguments.length == 0) {
  sample = 0;
} else {
  sample = arguments[0];
}

console.info("Launch WebCL-OSX sample ("+sample+") : "+samples[sample]);

webcl=require('../../webcl-node/webcl');

require('./'+samples[sample]);
