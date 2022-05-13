#include "predict.h"

static void features_loop(
        const F_base features[num_features],
        L_base latents[num_samples][num_latent],
		const M_base M[num_samples][num_latent],
		const B_base B[num_samples][num_features][num_latent]
		)
{
	for (int d = 0; d < num_features; d++)
	{


		const F_type feature = features[d];
		for (int s = 0; s < num_samples; s++)
			if (d == 0) {
				for (int k = 0; k < num_latent; k++)
				{
					L_type  v;
					v = M[s][k];
					L_type prod = feature * B[s][d][k];
					latents[s][k] = v + prod;
				}
			} else {
				for (int k = 0; k < num_latent; k++)
				{
					L_type  v;
					v = latents[s][k];
					L_type prod = feature * B[s][d][k];
					latents[s][k] = v + prod;
				}				
			}
	}
}

static void proteins_loop(
	P_base predictions[num_proteins],
	L_base latents[num_samples][num_latent],
    const U_base U[num_samples][num_proteins][num_latent]
	)
{
	for (int d = 0; d < num_proteins; d++)
	{
		S_type sum = .0F;
		for (int s = 0; s < num_samples; s++)
			for (int k = 0; k < num_latent; k++)
			{
				S_type prod = latents[s][k] * U[s][d][k];
				sum = sum + prod;
			}

		P_type aggr = sum / num_samples;
		predictions[d] = aggr;
	} // end proteins
}

void predict_compounds(
		int num_compounds, 
		const F_flx features,
		      P_flx predictions,
		const U_arr U,
		const M_arr M,
		const B_arr B)
{
    for (int i=0; i<num_compounds; ++i)
    {
        L_base latents[num_samples][num_latent];
        features_loop(features[i], latents, M, B);
        proteins_loop(predictions[i], latents, U);
	}
} // end function



