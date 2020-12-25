int inc(int count) {
    return ++count;
}

int main() {
    register volatile unsigned int x3 asm("x3");
    
    int count = 0;
    while(1) {
	//	if(count < 10)
	count = inc(count);
	//count++;
	x3=count;
    }
    return 0;
}
