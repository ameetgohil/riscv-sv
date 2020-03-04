int main() {
    register volatile unsigned int x3 asm("x3");
    volatile unsigned int *p;
    int count = 0xA;
    while(count < 100) {
	//	if(count < 10)
      if(count < 20)
	count++;
      else
	count += 2;
      x3=count;
      *p=count;
    }
    while(1);
    return 0;
}
