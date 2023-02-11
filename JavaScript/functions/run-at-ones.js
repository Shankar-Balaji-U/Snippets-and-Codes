function main() {
	console.log("Hello");
}
const CALLER_TIMEOUT = 5000;  			// 5 seconds
var is_called = true;

function run_ones() {
    if (is_called) {
        is_called = false;
        setTimeout(() => {
            main();
            is_called = true;
        }, CALLER_TIMEOUT);
    }
}

for (var i=0; i < 10; i++) {
	run_ones();
}
