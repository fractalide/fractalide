{ subgraph, imsgs, nodes, edges }:

subgraph rec {
 src = ./.;
 imsg = imsgs {
   edges = with edges; [ PrimU64 ];
 };
 flowscript = with nodes; with edges; ''
 '${imsg}.PrimU64:(u64=0)' ->  input inc1(${bench_inc_1000})
 inc1() output -> input inc2(${bench_inc_1000})
 inc2() output -> input inc3(${bench_inc_1000})
 inc3() output -> input inc4(${bench_inc_1000})
 inc4() output -> input inc5(${bench_inc_1000})
 inc5() output -> input inc6(${bench_inc_1000})
 inc6() output -> input inc7(${bench_inc_1000})
 inc7() output -> input inc8(${bench_inc_1000})
 inc8() output -> input inc9(${bench_inc_1000})
 inc9() output -> input inc10(${bench_inc_1000})
 inc10() output -> input inc11(${bench_inc_1000})
 '';
}
