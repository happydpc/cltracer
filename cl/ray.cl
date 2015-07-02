/** ray.cl */

#define RAY_FSIZE (9*sizeof(float))
#define RAY_ISIZE (3*sizeof(int))
#define RAY_FOFFSET 0
#define RAY_IOFFSET RAY_FSIZE
#define RAY_SIZE (RAY_FSIZE + RAY_ISIZE)

typedef struct
{
	float3 pos;
	float3 dir;
	float3 color;
	int2 origin;
	int source;
} 
Ray;

Ray ray_load(int offset, global const uchar *ray_data)
{
	Ray ray;
	global const uchar *data = ray_data + offset*RAY_SIZE;
	global const float *fdata = (global const float*)(data + RAY_FOFFSET);
	global const int *idata = (global const int*)(data + RAY_IOFFSET);
	ray.pos = vload3(0,fdata);
	ray.dir = vload3(1,fdata);
	ray.color = vload3(2,fdata);
	ray.origin = vload2(0,idata);
	ray.source = idata[2];
	return ray;
}

void ray_store(Ray *ray, int offset, global uchar *ray_data)
{
	global uchar *data = ray_data + offset*RAY_SIZE;
	global float *fdata = (global float*)(data + RAY_FOFFSET);
	global int *idata = (global int*)(data + RAY_IOFFSET);
	vstore3(ray->pos,0,fdata);
	vstore3(ray->dir,1,fdata);
	vstore3(ray->color,2,fdata);
	vstore2(ray->origin,0,idata);
	idata[2] = ray->source;
}
