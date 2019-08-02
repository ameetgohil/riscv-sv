int main() {
    register volatile unsigned int x3 asm("x3");
    
    int count = 0;
    while(1) {
	count++;
	x3=count;
    }
    return 0;
}
