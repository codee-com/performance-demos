#include <stdio.h>
#include <math.h>
#include <time.h>
#include <stdlib.h>

#include "predict.h"
#include "vms_tb.h"

const float epsilon = 0.5;
const int float_size = sizeof(float) * 8;

#ifdef _OPENMP
#include <omp.h>
double tick() {
    return (double)omp_get_wtime();
}
#else
double tick() {
    return (double)clock() / CLOCKS_PER_SEC;
}
#endif

void prepare_tb_input(
    int num_compounds,
    const float in[tb_num_compounds][num_features],
    F_base out[][num_features])
{
    for (int c = 0; c < num_compounds; c++)
        for (int p = 0; p < num_features; p++)
            out[c][p] = in [c%tb_num_compounds][p];
}

int check_result(
    int num_compounds,
    P_base out[][num_proteins],
    const float ref[tb_num_compounds][num_proteins])
{
    int nerrors = 0;
    for (int c = 0; c < num_compounds; c++)
        for (int p = 0; p < num_proteins; p++)
        {
            float o = out[c][p];
            float r = ref[c % tb_num_compounds][p];
            if (fabs(o - r) < epsilon)
            {
                //printf("ok at [%d][%d]: %f == %f\n", c, p, o, r);
            }
            else
            {
                printf("error at [%d][%d]: %f != %f\n", c, p, o, r);
                nerrors++;
            }
        }

    printf("%d errors (out of %d)\n", nerrors, num_compounds * num_proteins);
    return nerrors;
}

int main(int argc, char *argv[])
{
    int num_repeat = 1;
    int num_compounds = 10;


    if (argc > 1 && atoi(argv[1]))
    {
        num_repeat = atoi(argv[1]);
    }

    if (argc > 2 && atoi(argv[2]))
    {
        num_compounds = atoi(argv[2]);
    }
   
    P_base (*tb_output_block)[num_proteins] = (P_base (*)[num_proteins])malloc(sizeof(P_base) * num_compounds * num_proteins);
    F_base (*tb_input_block)[num_features]  = (F_base (*)[num_features])malloc(sizeof(F_base) * num_compounds * num_features); 

    printf("  dt:    %s\n", DT_NAME);
    printf("  nrep:  %d\n", num_repeat);
    printf("  nprot: %d\n", num_proteins);
    printf("  ncmpd: %d\n", num_compounds);
    printf("  blks:  %d\n", block_size);
    printf("  nfeat: %d\n", num_features);
    printf("  nlat:  %d\n", num_latent);
    printf("  nsmpl: %d\n", num_samples);

    int nerrors = 0;

    printf("Prepare input\n");
    prepare_tb_input(num_compounds, tb_input, tb_input_block);

    printf("Predicting\n");
    double start = tick();
    for(int n=0; n<num_repeat; n++)
    {
        predict_compounds(num_compounds, tb_input_block, tb_output_block, U, M, B);
    }
    double stop = tick();
    nerrors += check_result(num_compounds, tb_output_block, tb_ref);
    double elapsed = stop-start;
    printf("took %.2f sec; %.2f compounds/sec\n", elapsed, num_compounds * num_repeat / elapsed);

    // terra-ops aka 10^12 ops
    double tops = (double)num_repeat * (double)num_samples * (double)num_compounds * (double)num_latent * (double)(num_features + num_proteins) / 1e12;
    printf("%.4f tera-ops; %.4f tera-ops/second (%d-bit floating point ops)\n", tops, tops/elapsed, float_size);
    printf("%.4f giga-ops; %.4f giga-ops/second (%d-bit floating point ops)\n", 1e3 * tops, 1e3 * tops/elapsed, float_size);
    return nerrors;
}
