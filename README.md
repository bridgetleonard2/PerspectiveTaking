# PerspectiveTaking: A Multimodal Spatial Cognition Assessment Benchmark

## Overview

This repository accompanies a NeurIPS workshop paper submission, providing a benchmark for multimodal spatial cognition assessment with a focus on **perspective taking**. This benchmark explores how AI models approach tasks involving the mental rotation and transformation of objects, tested through tasks commonly used in human cognitive science.

### Why Perspective Taking Matters

Understanding spatial cognition is fundamental for the development of AI systems that interact meaningfully with the world. Perspective taking is a core cognitive process that allows humans to interpret spatial relationships between objects from different viewpoints. This ability develops over time in human cognition and has been studied extensively in cognitive science.

The methods we use to assess AI systems must accurately reflect the cognitive processes we are interested in. By leveraging cognitive science benchmarks, we can compare AI and human cognitive abilities on a developmental timeline, fostering a better understanding of both systems. This ensures that we are measuring not just performance, but whether AI systems are truly learning the cognitive skills humans rely on.

## Repository Structure

The repository is organized into the following directories:

PerspectiveTaking/
├── GPT/                    # Contains code to run GPT task and results
│   └── results/            # GPT task data (e.g., experimental results)
│   └── gpt_task.py         # API code to run the task
│   └── plot_data.py        # Analysis for GPT task
├── Human/                  # Contains code to run human task and results
│   └── data/               # Human task data (e.g., experimental results)
│   └── experiments_code/   # Psychtoolbox experiments code
│   └── averageResults.m    # Analysis for human task
├── images/                 # Benchmark images
│   └── bitmap              # bitmap version for PTB experiments
│   └── jpeg                # jpeg versions for API experiments
├── README.md               # Project overview (this file)
├── requirements.txt        # Dependencies for running the project
└── LICENSE                 # License information

