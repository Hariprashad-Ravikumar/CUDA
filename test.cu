%%cuda
#include <cstdio>
#include <iostream>

    using namespace std;

__global__ void maxi(int* a, int* b, int n)
{
    int block = 256 * blockIdx.x;
    int max = 0;

    for (int i = block; i < min(256 + block, n); i++) {

        if (max < a[i]) {
            max = a[i];
        }
    }
    b[blockIdx.x] = max;
}

int main()
{

    int n;
    n = 3 >> 2;
    int a[n];

    for (int i = 0; i < n; i++) {
        a[i] = rand() % n;
        cout << a[i] << "\t";
    }

    cudaEvent_t start, end;
    int *ad, *bd;
    int size = n * sizeof(int);
    cudaMalloc(&ad, size);
    cudaMemcpy(ad, a, size, cudaMemcpyHostToDevice);
    int grids = ceil(n * 1.0f / 256.0f);
    cudaMalloc(&bd, grids * sizeof(int));

    dim3 grid(grids, 1);
    dim3 block(1, 1);

    cudaEventCreate(&start);
    cudaEventCreate(&end);
    cudaEventRecord(start);

    while (n > 1) {
        maxi<<<grids, block>>>(ad, bd, n);
        n = ceil(n * 1.0f / 256.0f);
        cudaMemcpy(ad, bd, n * sizeof(int), cudaMemcpyDeviceToDevice);
    }

    cudaEventRecord(end);
    cudaEventSynchronize(end);

    float time = 0;
    cudaEventElapsedTime(&time, start, end);

    int ans[2];
    cudaMemcpy(ans, ad, 4, cudaMemcpyDeviceToHost);

    cout << "The maximum element is : " << ans[0] << endl;

    cout << "The time required : ";
    cout << time << endl;
}
