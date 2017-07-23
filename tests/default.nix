/* Simple test file for fractalide
*/
{
  test_nand  = (import ../. { node = "test_nand"; }).pkg;
  bench      = (import ../. { node = "bench"; }).pkg;
  bench_load = (import ../. { node = "bench_load"; }).pkg;
}
