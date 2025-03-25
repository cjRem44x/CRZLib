#include <stdio.h>

float inv_sqrt(float n) 
{
    long i;
    float x2, y;
    const float threehalfs = 1.5F;

    x2 = n * 0.5F;
    y = n;
    i = *( long *) &y;
    i = 0x5f3759df - (i >> 1);
    y = * (float *) &i;
    y = y* ( threehalfs - (x2*y*y) );
    return y;
}

int main()
{
    printf("%f\n", 1.0F/inv_sqrt(3.4));
    return 0;
}
