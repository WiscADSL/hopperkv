# HopperKV Artifact

This document describe the procedure to reproduce the experiments in FAST'26 paper *Cache-Centric Multi-Resource Allocation for Storage Services*. The original experiments in the paper run on a AWS EC2 cluster with real DynamoDB. This instructions provides to reproduce all experiments on CloudLab with a mocked DynamoDB backend, which enables an easy-to-use development environment without expensive AWS bills.

## Cluster Setup

Experiments require one machine for the server and several for the clients. The provided scripts by default assume a cloudlab cluster with 7 machines, where node0 (10.10.1.1) is the server, and the rest (10.10.1.2, ...) are the clients.

Setup requirements:

- All nodes must have `hopperkv` downloaded in the save path.
- The server node must be able to `ssh` into other clients machines without passwords.

All scripts assume running on the server's `hopperkv/`.

## Quick Reproduction

On the server machine, run `prepare_artifact.sh`, which initializes the current server machine and ssh into other clients machines and do initialization. This should only run once; skip if already done.

```shell
bash experiments/prepare_artifact.sh  # this take ~3.5 hours
```

Then run all experiments

```shell
bash experiments/run_artifact.sh
```

This will generate the following figures:
- `results/exper_var_ws/fixed_ws=6m/perf_resrc.pdf` (Figure 6a)
- `results/exper_var_distrib_6m_0.99/ws=12m/perf_resrc.pdf` (Figure 6b)
- `results/exper_scale/norm_tput_cdf.pdf` (Figure 7a)
- `results/exper_scale/norm_tput.pdf` (Figure 7b)
- `results/exper_dyn/tput_timeline.pdf` (Figure 8)
- `results/exper_trace_512m/norm_tput_cdf.pdf` and `results/exper_trace_512m/norm_tput.pdf` (Figure 9a)
- `results/exper_trace_1g/norm_tput_cdf.pdf` and `results/exper_trace_1g/norm_tput.pdf` (Figure 9b)


## Detailed Reproduction Instructions

This section provides detailed instructions and explanation for experiments in [**Quick Reproduction**]((#quick-reproduction)); feel free to skip.

### Set up Environments

The operation below only needs to be done once (through it is safe to re-run any scripts).

#### Install Dependencies

To install all dependencies, run `scripts/init_server.sh`:

```shell
bash scripts/init_server.sh
```

#### Create Checkpoints

Since it takes very long time to warm up Redis, we will pre-create a few Redis checkpoints and load these checkpoints for experiments. The scripts below will create and save these checkpoints in `ckpt/`. The rest of experiments reply on these checkpoints.

```shell
# create general checkpoints
bash experiments/create_ckpt.sh
# create checkpoints specifically for policy "Non-Part" (aka. "global")
bash experiments/create_ckpt_scale_global.sh  # for scaling macrobenchmark
bash experiments/create_ckpt_dyn_global.sh    # for dynamic macrobenchmark
```

#### Download and Preprocess Twitter Trace

The Twitter trace-replay experiments require downloading the twitter trace and preprocess the traces. Since the full traces are very large, the scripts will only take a prefix of each.

```shell
bash replay/download_preprocess_trace.sh
bash replay/trim_cache.sh
```

### Microbenchmarks

The microbenchmarks contain two experiments: 1. varying working set size and 2. varying hotness distribution:

```shell
bash experiments/run_var_ws.sh       # varying working set size
bash experiments/run_var_distrib.sh  # varying hotness distribution
```

This should produce two figures `results/exper_var_ws/fixed_ws=6m/perf_resrc.pdf` (Figure 6a in the paper) and `results/exper_var_distrib_6m_0.99/ws=12m/perf_resrc.pdf` (Figure 6b).

### Scaling Macrobenchmark

To run scaling macrobenchmark:

```shell
bash experiments/run_scale.sh
```

This should produce two figures `results/exper_scale/norm_tput_cdf.pdf` (Figure 7a) and `results/exper_scale/norm_tput.pdf` (Figure 7b).

### Dynamic Macrobenchmark

To run dynamic macrobenchmark:

```shell
bash experiments/run_dyn.sh
```

This should produce a figure `results/exper_dyn/tput_timeline.pdf` (Figure 8).

### Dynamic Trace-Replay Macrobenchmark

The trace-replay macrobenchmarks run in two settings, one with 0.5GB baseline cache and another with 1GB:

```shell
bash experiments/run_trace_512m.sh  # with 0.5GB baseline cache
bash experiments/run_trace_1g.sh    # with 1GB baseline cache
```

This should produce four figures `results/exper_trace_512m/norm_tput_cdf.pdf` and `results/exper_trace_512m/norm_tput.pdf` (Figure 9a) and `results/exper_trace_1g/norm_tput_cdf.pdf` and `results/exper_trace_1g/norm_tput.pdf` (Figure 9b).
