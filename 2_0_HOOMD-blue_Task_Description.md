[toc]

# HOOMD-blue Task Description

## 1. Task workload and input

Participants are required to optimize the following workload for improved performance.

### Workload Profile

- **Workload**: [md_pair_wca](https://github.com/glotzerlab/hoomd-benchmarks/tree/trunk?tab=readme-ov-file#simulation-benchmarks)
- **Number of particles**: `200,000`
- **Input data**:hard_sphere_200000_1.0_3.gsd`
- **Recommended warm up and benchmark iterations**

| Number of nodes | NCI Gadi iterations<br />(Warm up/Benchmark) | NSCC SG Aspire-2A iterations<br />(Warm up/Benchmark) |
| --------------- | -------------------------------------------- | ----------------------------------------------------- |
| 32              | 10,000/320,000                               | 1/1 {Failed to run}                                   |
| 16              | 10,000/160,000                               | 1/1 {Failed to run}                                   |
| 8               | 40,000/80,000                                | 40,000/80,000                                         |
| 4               | 40,000/80,000                                | 40,000/80,000                                         |
| 2               | 40,000/80,000                                | 40,000/80,000                                         |
| 1               | 40,000/80,000                                | 40,000/80,000                                         |

## 2. Submission and Presentation

- Submit all your `build scripts`, `run scripts`, and `output text` files (e.g., *.stdout, *.o{jobid}, etc.)
- Prepare slides for your team’s interview based on your application tuning work.

## 3. Rules

- The results will be executed on `up to 32 normal CPU servers`.
- Grading will  based on the `optimization method` and the `performance improvement` achieved.
- Participants may use any version of tagged HOOMD-blue code available at [Releases · hoomd-blue](https://github.com/glotzerlab/hoomd-blue/releases) or the HOOMD-blue GitHub code from the default branch.

## 4. General Rules

- **Cluster Usage**: All HPC and AI tasks must be optimized on either the NCI or NSCC SG supercomputers. Teams can choose which tasks to optimize on which supercomputer. Additionally, teams may present optimization work done on other supercomputers as extra information.
- **Evaluation Criteria**: The judging panel will assess each team’s methods for optimizing cluster application throughput. Teams must clearly explain and demonstrate the performance improvements achieved through their optimization techniques, showing a solid understanding of their methods.
- **System Reliability**: Teams do not need to worry about system maintenance. If either the NCI or NSCC SG supercomputer is down for maintenance, teams can switch to the other operational system to continue their optimization work, ensuring the competition runs smoothly.
- **Performance Assessment**: The absolute performance metrics of NCI and NSCC SG will not be directly compared. These metrics will indicate the effectiveness of the system tuning and will be a significant factor in the judges’ scoring. However, they will not be the only criteria for ranking teams.
- **Scoring Flexibility**: When performance metrics are close, the judges will consider how well teams understand and explain their optimization process. This ensures that both technical results and the team’s comprehension are fairly evaluated.