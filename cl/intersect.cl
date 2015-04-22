__kernel void intersect(
	__global const float *ray_fdata, __global const int *ray_idata,
	__global float *hit_fdata, __global int *hit_idata, 
	__global uint *hit_info, __global const uint *work_size
)
{
	const int size = get_global_size(0);
	const int pos = get_global_id(0);
	
	if(pos >= *work_size)
	{
		return;
	}
	
	Ray ray = ray_load(pos,ray_fdata,ray_idata);
	
	// Collide with uniform sphere
	const float3 sph_pos[3] = {(float3)(0.0f,4.0f,0.0f),(float3)(3.0f,6.0f,0.0f),(float3)(0.0f,4.0f,-4.0f)};
	const float sph_rad[3] = {1.0f,1.6f,2.4f};
	int i, hit_obj = 0;
	float min_dist;
	float3 hit_pos, hit_norm;
	for(i = 0; i < 3; ++i)
	{
		float dist = dot(sph_pos[i] - ray.pos,ray.dir);
		float3 lpos = ray.pos + dist*ray.dir;
		float len = length(lpos - sph_pos[i]);
		float dev = sqrt(sph_rad[i]*sph_rad[i] - len*len);
		float3 hpos = lpos - ray.dir*dev;
		dist -= dev;
		if(dist > 0.0f && len < sph_rad[i])
		{
			if(hit_obj == 0 || dist < min_dist)
			{
				min_dist = dist;
				hit_pos = hpos;
				hit_obj = i + 1;
				hit_norm = (hit_pos - sph_pos[i])/sph_rad[i];
			}
		}
	}
	
	Hit hit;
	hit.pos = hit_pos;
	hit.dir = ray.dir;
	hit.norm = hit_norm;
	hit.color = ray.color;
	hit.origin = ray.origin;
	hit.object = hit_obj;
	
	HitInfo info;
	info.size = 2*(hit_obj > 0);
	info.offset = 2*(hit_obj > 0);
	hit_info_store(&info,pos,hit_info);
	
	hit_store(&hit,pos,hit_fdata,hit_idata);
}