[toc]

# Frequently Asked Questions

## Q1. Scoring Criteria Across Different Supercomputers

**Q:** I am concerned that the work done on the one of the Supercomputer might be at a disadvantage when directly compared with the results from the other Supercomputer. So, I want to confirm if the scoring criteria are based solely on the evaluation of the `optimization methods`, rather than the specific performance metrics of each system. Is my understanding correct?
**A:** Absolutely correct.

## Q2. Llama Finetuning Methods for the Competition

**Q:** Are there any restrictions on the methods for finetuning Llama, or can we use any method?

**A:** The competition tasks uses the `LitGPT Llama2-7B finetune-full` workload, and only throughput improvements will be compared. To maintain focus and consistency, we are not using LoRA settings, as this can lead to extensive efforts in parameter tuning and exhausting teams with various LoRA parameter combinations.

## Q3. Using LoRA for Fine-Tuning in the Competition?

**Q:** So, if we use LoRA for fine-tuning, will the scores still be counted, even though it might take more time for the team?

**A:** No. Please focus on the `finetuning-full` workload.

While LoRA can make the system optimization competition more flexible, it may confuse judges who are not familiar with AI models.

Initially, we considered a version of the rules where all LoRA parameters had to use the values from the LitGPT config_hub to ensure an `“apple to apple”` comparison in system optimization, maintaining consistent model size and computation load.

We considered these LoRA rules due to concerns that running finetune-full on eight 32GB V100 GPUs might result in out-of-memory errors. However, in practice, even four V100 GPUs can run the `Llama2-7B finetune-full` with the customized `Max seq length 512` defined in the `LitGPT config_hub`.

Given the principles of `“apple to apple”` comparisons and `consistent model size and computation load`, it is simpler to use finetune-full and avoid the complexities of LoRA. Moreover, with fixed LoRA parameter values, the experience of running and optimizing finetune-LoRA is essentially the same as finetune-full.

## Q4. Presentation for the AI Task

**Q:** What is the main goal of the AI task, and how should we do a nice presentation to showcase our tuning work?

**A:** The primary objective of this competition is to optimize `“HPC-AI workloads”` on supercomputers, rather than developing a superior model based on Llama2. Unlike open competitions such as Kaggle, this is a closed-division benchmarking task.

Given this context, it is crucial to develop and showcase your system `profiling and tuning` skills. This not only assists supercomputer managers and users in optimizing their systems but also enhances your own tuning capabilities.

In addition to the competition rules, some AI competition teams in previous years have performed optimizations on `other supercomputers`, such as their own Supercomputers, outside the specified rules and parameters. However, this kind of continuous optimization can become an endless task until the system reaches its end of life, such as a P100 GPU AI training cluster, requiring significant effort and time.

While this extended optimization is `not a standard metric for grading or ranking`, the committee sometimes appreciates such efforts and may award bonus points for exceptional presentations.



## Q5. Requesting Additional SU on Gadi

**Q:** If we run out of SU on Gadi, can we request more?

**A:** Yes, you can. When you are about to run out of SU, please send an email to pengzhiz@hpcadvisorycouncil.com.

## Q6. Disk Quota Issues When Installing LitGPT

**Q:** When trying to install litgpt, I encountered the error: 

`"ERROR: Could not install packages due to an OSError: [Errno 122] Disk quota exceeded."` I checked the disk quota using the `quota` command and found that it is only 10GB, which doesn't seem to be enough space.

**A:** Please refer to the “0. Basic Supercomputer Environment Setup.md” to move PIP and HuggingFace cache files to the `scratch` directory to save disk quota in your home directory.

## Q7. The HOOMD-Blue LOG_CAT_ML HCOLL issue

**Q:** `[LOG_CAT_ML] component basesmuma is not available but requested in hierarchy: basesmuma,basesmuma,ucx_p2p:basesmsocket,basesmuma,p2p`

**A:** Please refer to HOOMD-blue Application Notes.md
