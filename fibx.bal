import ballerina/io;
import ballerina/time;

function main(string... args) {
    while (true) {
        int startTime = time:currentTime().time;
        int x = fibx(32);
        int end = time:currentTime().time;
        io:println(x);
        io:println("Time: " + (end - startTime) + " ms.");
    }
}

function fibx(int n) returns @untainted int {
    if (n == 0 || n == 1) {
        return 1;
    } else {
        return fibx(n - 1) + fibx(n - 2);
    }
}