---
title: "Google AI Studio"
source: "https://aistudio.google.com/prompts/1l6LmKlap158IBJwe8YhD_q1kCdCpvpWn"
author:
published:
created: 2026-05-11
description: "The fastest path from prompt to production with Gemini"
---

## Qwen3.6-35B-A3B on RTX 5070 TI and 64 GB DDR5 6 GHz

> [!NOTE] Prompt
> 
> I need info on running Qwen3.6-35B-A3B on RTX 5070 TI and 64 GB DDR5 6 GHz

Running **Qwen3.6-35B-A3B** (released in April 2026) on an **RTX 5070 Ti** and **64 GB of DDR5-6000 RAM** is a highly capable setup, provided you manage your VRAM limits correctly. 

Here is everything you need to know about how this model interacts with your specific hardware and the best strategies for running it.

### 1. Hardware & Model Dynamics

* **The Model (Qwen3.6-35B-A3B):** The "A3B" stands for **Active 3 Billion**. This is a sparse Mixture-of-Experts (MoE) model that has 35 billion *total* parameters, but only activates 3 billion parameters per token during generation. It also uses a hybrid architecture combining standard gated attention with Gated DeltaNet linear attention.
* **The GPU (RTX 5070 Ti):** Launched in early 2025, your GPU gives you 16 GB of ultra-fast GDDR7 VRAM (with 896 GB/s bandwidth). 
* **The System RAM (64 GB DDR5 @ 6 GHz):** This is your secret weapon. Because this is an MoE model, offloading parts of it to system RAM is drastically more efficient than offloading a standard dense model.

### 2. Memory Math & Quantization 

At its native BF16 precision, the model requires roughly 70 GB of memory, which exceeds your GPU capacity. To run it, you must use **quantization**.

* **4-bit Quantization (e.g., GGUF `Q4_K_M`):** ~19 GB
* **5-bit Quantization (e.g., GGUF `Q5_K_M`):** ~22 GB
* **3-bit Quantization (e.g., GGUF `Q3_K_M`):** ~14.5 GB

Because your GPU has 16 GB of VRAM, an uncompressed or even a 5-bit model will not fit fully into the GPU. 

### 3. Recommended Deployment Strategies

#### Strategy A: The GPU/CPU Split (Highly Recommended)

Your best option is to use a **4-bit GGUF (`Q4_K_M`)** using a backend like `llama.cpp`, Ollama, or LM Studio. 
* **How it works:** You load ~12 GB of the model into your RTX 5070 Ti's VRAM, and offload the remaining ~7 GB into your 64 GB DDR5 system RAM. 
* **Why this is optimal:** Normally, splitting a model across CPU and GPU destroys text generation speed. However, because Qwen3.6 only activates 3B parameters per token, the CPU only has to calculate a tiny fraction of the weights. Your 6 GHz DDR5 RAM is fast enough that you will still achieve excellent, highly responsive token generation speeds.
* **VRAM Buffer:** By keeping the GPU payload to 12 GB, you leave 4 GB of your GDDR7 VRAM completely free for the **KV Cache** (context window). 

#### Strategy B: Full GPU Inference (Max Speed, Lower Quality)

If you absolutely demand pure GPU inference speeds, you can use a **3-bit GGUF (`Q3_K_M`)** or INT3/EXL2 format to squeeze the entire model into ~14.5 GB of VRAM. 
* **The downside:** This leaves only 1.5 GB of VRAM for your context window. For an agentic model like Qwen3.6, which relies on a new feature called "Thinking Preservation" (retaining historical reasoning contexts), starving the context window will severely limit its coding and reasoning capabilities. 

### 4. Software Stack & Best Practices

Due to Qwen3.6's hybrid DeltaNet architecture, you must ensure your inference tools are up to date (as of mid-2026):

* **Download Unsloth Quants:** Look for the **Dynamic 2.0 GGUF** builds published by the Unsloth team (e.g., `unsloth/Qwen3.6-35B-A3B-GGUF`). These quants are benchmarked as state-of-the-art for this specific model, tracking the original BF16 quality closely and minimizing the "dumb-down" effect usually seen in MoE quantization.
* **Manage Context Length:** While the model natively supports up to 262,000 tokens, you physically do not have the VRAM for that. With 4 GB of VRAM dedicated to the KV cache, expect to comfortably run around **8k to 16k context**. If you need larger document analysis, shift more of the model layers to your 64 GB system RAM to free up VRAM for context.
* **Flash Attention / MTP:** Make sure your engine has Multi-Token Prediction (MTP) and Flash Attention enabled to get the absolute most out of the 5070 Ti's new Blackwell-architecture Tensor cores.

---

## 8 Bit Weight Quantization

> [!NOTE] Prompt
> 
> What about 8bit with offloading?

Running an **8-bit quantization** (like GGUF `Q8_0`) with offloading is an excellent idea for maximizing reasoning and coding quality. Because you have 64 GB of system RAM, you are uniquely positioned to handle the larger footprint without your system breaking a sweat.

Here is exactly how the 8-bit offloading strategy breaks down on your RTX 5070 Ti and DDR5-6000 setup:

### 1. The Memory Math for 8-Bit

An 8-bit version of a 35B parameter model requires exactly 1 byte per parameter. Adding in overhead for metadata, embeddings, and vocabulary, a `Q8_0` or `Q8_K_M` GGUF file will sit right around **37 GB**. 

Here is how your hardware will split that load:
* **GPU (RTX 5070 Ti):** You will load roughly **10 to 12 GB** of the most frequently used layers onto the GPU.
* **CPU/System RAM:** You will offload the remaining **25 to 27 GB** into your system memory.
* **Leftover RAM:** You will still have roughly **35 GB of system RAM completely free** for your OS, IDEs, and browser, meaning your PC will not lock up or resort to paging. 

### 2. The Speed vs. Quality Trade-off

Moving from 4-bit to 8-bit changes the dynamic of your system considerably:

* **The Quality (Near-Perfect):** At 8-bit, the degradation of the model weights is practically zero. You are getting the exact same reasoning capabilities, instruction following, and coding accuracy as the native BF16 model. For complex logic tasks, this is a massive upgrade over 4-bit.
* **The Speed (The DDR5 Bottleneck):** This is where your MoE (Mixture of Experts) architecture saves you. If this were a *dense* 35B model, fetching 8-bit weights from system RAM across the CPU memory bus would slow generation down to a painful 3–5 tokens per second. 
* **MoE to the Rescue:** Because Qwen3.6-35B-A3B only activates **3 Billion parameters** per token, the amount of data your 6 GHz DDR5 memory needs to fetch dynamically is quite small. You can expect highly interactive generation speeds—likely hovering around **20 to 30 tokens per second**. It is slightly slower than the 4-bit split, but entirely comfortable for real-time reading and coding.

### 3. Maximizing the Context Window (KV Cache)

Because you have so much extra system RAM, you have a distinct advantage here.

The context window (KV Cache) needs to be stored somewhere, and storing it in VRAM is always faster. Because you are using 8-bit weights, you can deliberately choose to offload *more* of the model to your system RAM (e.g., put 30 GB in RAM and only 7 GB on the GPU). 

By shrinking the model's footprint on the GPU, you leave **6 to 8 GB of VRAM entirely dedicated to the KV Cache**. This allows you to comfortably run **32k+ token contexts** entirely in your ultra-fast GDDR7 VRAM. You can paste massive codebases or long documentation into the prompt without the "Time to First Token" (prompt processing time) taking several minutes.

### How to configure this in your backend (llama.cpp / Ollama):

1. **Download the `Q8_0` GGUF** for Qwen3.6-35B-A3B.
2. **Tune `n_gpu_layers`:** Start by setting your GPU offload layers to roughly **30-40%** of the total layers. Monitor your VRAM usage in Task Manager. 
3. **Leave Headroom:** Increase the layers offloaded to the GPU until you hit about **11 GB of VRAM usage**. Stop there. Leave that remaining 5 GB of your 5070 Ti's VRAM empty—the model will aggressively fill it with the KV cache as soon as you start chatting with it.

---

## 128K Context

> [!NOTE] Prompt
> 
> How much do I lose on 4bit context? What if I lower to 128K?

Here is a realistic look at what happens when you crush the context window down to 4-bit, and why dropping to 128K might actually be the ultimate sweet spot for your hardware.

### 1. What do you lose with a 4-bit KV Cache?

When you quantize the KV cache (the model's "memory"), you are not changing the model's core intelligence, but you are lowering the resolution of its short-term memory. At 4-bit, the model experiences a slight "fuzziness" regarding older tokens. 

Here is how that plays out in practice:
* **"Needle in a Haystack" Failures:** If you feed the model a 200,000-token log file and ask for a specific IP address buried on line 4,302, a 4-bit KV cache has a higher chance of hallucinating a digit or failing to find it altogether compared to FP16. 
* **Coding Precision:** If you paste in an entire codebase, the model might remember the *logic* of a function written 150K tokens ago, but it might misspell a specific variable name or hallucinate the exact arguments that function takes.
* **Creative / Summarization (Minimal Impact):** If you are asking it to summarize two large novels or write an essay based on a massive document, you likely won't notice the 4-bit degradation at all. The overarching themes and semantic meanings survive 4-bit quantization perfectly fine.

### 2. What happens if you lower the context to 128K?

Dropping from 256K to 128K is a game-changer for your RTX 5070 Ti and 64 GB DDR5 setup. It unlocks two distinct, highly optimized pathways:

#### Pathway A: The "Lossless Memory" Route (8-bit KV Cache)

By halving the context to 128K, you halve the memory requirement. This means you can afford to upgrade your KV cache from 4-bit back up to **8-bit (`q8_0`)**.
* **The Math:** 128K at 8-bit KV requires about **16 GB of VRAM**.
* **The Benefit:** 8-bit KV cache is practically indistinguishable from native FP16. You get near-perfect "Needle in a Haystack" recall. For deep coding tasks, legal document analysis, or rigorous data extraction, this ensures the model won't make silly precision errors. 
* *Note: Like the 256K setup, this still occupies your entire GPU with context, leaving the model weights entirely in your system RAM. Prompt processing will still be somewhat slow.*

#### Pathway B: The "Speed Demon" Route (4-bit KV + GPU Offloading)

If you keep the 4-bit KV cache but reduce the context to 128K, the context footprint drops from 16 GB down to just **8 GB**. 
* **The GPU Split:** You now have 8 GB of VRAM dedicated to the context, and **8 GB of empty VRAM** on your RTX 5070 Ti. 
* **The Speed Boost:** You can now move 8 GB of the actual model weights out of your DDR5 system RAM and onto your blazing-fast GDDR7 GPU. 
* **The Benefit:** This dramatically alleviates the DDR5 bottleneck. Your "Time to First Token" (prompt processing) for large documents will drop from several minutes to just seconds. Your token generation speed will easily jump past 30+ tokens per second.

### Summary Recommendation

* **Stick to 256K (4-bit KV):** Only if you absolutely *must* fit a colossal amount of text into a single prompt and are okay with waiting a few minutes for the first response, accepting a slight drop in perfect recall.
* **Drop to 128K (8-bit KV):** If you need absolute, flawless precision for a very large (but not colossal) codebase or dataset.
* **Drop to 128K (4-bit KV):** **(Best Overall)** This gives you a massive context window while freeing up enough GPU VRAM to make the model feel snappy, responsive, and incredibly fast.

---

## Mixed-Precision KV Cache

> [!NOTE] Prompt
> 
> Are there ways to have some kind of mixed mode 4 and 8 bit KV cache mode to keep precision and improve performance?

Yes, absolutely. In fact, utilizing a **mixed-precision KV cache** is currently the most advanced optimization strategy for local LLM running. 

Researchers and engine developers (like the teams behind `llama.cpp` and `vLLM`) discovered that you do not have to treat the entire context memory exactly the same. By mixing 8-bit and 4-bit quantization, you can retain the flawless "Needle in a Haystack" recall of an 8-bit cache while capturing the memory savings and speed of a 4-bit cache.

Here are the specific mixed-mode strategies available to you for your **RTX 5070 Ti** and **Qwen3.6-35B-A3B**, and how to implement them.

### 1. The "K8 / V4" Asymmetric Split (Most Recommended)

To understand this, you need to know that the KV Cache has two halves: **Keys (K)** and **Values (V)**.
* **The Key (K):** Acts as the address/router. It tells the model *where* to look in its memory. 
* **The Value (V):** Is the actual payload/data stored at that address.

Research (such as the KIVI algorithm) proved that the model is incredibly sensitive to the precision of the **Key** cache, but highly resilient to the compression of the **Value** cache. If the model miscalculates the Key, it pulls the wrong memory entirely. If it slightly fuzzes the Value, it can still understand the semantic meaning.

**How to use it:**
You force the engine to keep the Keys at 8-bit (for perfect memory routing) and crush the Values to 4-bit (to save VRAM).
* **Memory Footprint at 128K:** Instead of 16 GB (Full 8-bit) or 8 GB (Full 4-bit), this split sits right in the middle at roughly **12 GB of VRAM**.
* **Hardware Fit:** This is perfect for your RTX 5070 Ti. It consumes 12 GB of VRAM for the massive 128K context, leaving exactly 4 GB of VRAM free to offload a few layers of the model to the GPU for a speed boost.
* **Implementation:** If you are using a `llama.cpp` backend (like Ollama, LM Studio, or KoboldCPP), you would pass the following execution flags: 
    `--cache-type-k q8_0 --cache-type-v q4_0`

### 2. Layer-Wise Mixed Precision (PM-KVQ)

Another approach focuses on the *layers* of the model rather than the K/V split. Qwen3.6-35B-A3B has dozens of neural network layers. 

* **The Concept:** The early layers (which establish the core understanding of the prompt) and the middle layers (where the heavy logic happens) are kept at **8-bit KV precision**. The late layers (which mostly just format the output text) are downgraded to **4-bit** or even 2-bit.
* **The Benefit:** You retain 99% of the reasoning capability but cut your memory footprint by about 30%.
* **Implementation:** This is heavily supported in the `vLLM` engine via progressive mixed-precision configs. You configure an engine YAML file to dictate: `Layers 0-20: e5m2 (8-bit)`, `Layers 21-end: e4m3 (4-bit)`.

### 3. Dynamic "Hot / Cold" Token Quantization

A newer capability (often referred to as StreamingLLM or dynamic KV eviction/quantization) looks at the *age* of the tokens. 
* **How it works:** The most recent 4,000 tokens of your conversation are kept in native FP16 or 8-bit. As tokens age out and become "cold" (e.g., the code you pasted 50,000 tokens ago), the engine dynamically compresses them down to 4-bit in the background.
* **The Benefit:** You get blazing-fast, high-precision responses for the immediate conversation, but you don't run out of memory holding onto the distant past. 

### What You Should Do:

For your specific setup (RTX 5070 Ti + 64 GB DDR5 + 128K context requirement), **The K8/V4 Split is the undisputed king.** 

1. Load your 8-bit model (`Q8_0` GGUF) mostly into your 64 GB system RAM.
2. Set `-ctk q8_0` (Key cache to 8-bit) and `-ctv q4_0` (Value cache to 4-bit).
3. Load the 12 GB mixed KV cache entirely into your GPU.
4. Use the remaining 4 GB of VRAM to offload the heaviest 3 to 5 layers of the model.

This gives you an agent that can ingest an entire 128,000-word codebase with zero "Needle in a Haystack" logic failures, while avoiding the VRAM overflow that would normally crash a 16 GB GPU.

---

## Dynamic KV Cache Allocation

> [!NOTE] Prompt
> 
> Can I have dynamic context size increase?

Yes, you absolutely can. The feature you are looking for is called **Dynamic KV Cache Allocation** (often powered by a technology called **PagedAttention**), and it is fully supported by modern inference engines.

In the older days of local AI, if you requested a 128K context, the engine would instantly reserve a massive, empty 12 GB block of your GPU's VRAM right at startup. This was incredibly wasteful if you only intended to ask a quick coding question.

Here is how dynamic context works on your RTX 5070 Ti and 64 GB DDR5 setup, and how to configure it so your system scales intelligently.

### 1. How Dynamic Context (PagedAttention) Works

Instead of pre-allocating one giant block of memory, the engine breaks the context window into tiny "blocks" or "pages" (usually 16 or 32 tokens each). 
* **Startup:** When you load the model, the KV cache uses **0 GB**.
* **Small Prompts:** If you paste in a 4,000-token script, the engine dynamically allocates just the few megabytes needed for those specific pages.
* **Scaling Up:** As the conversation continues and the model generates more text, the engine seamlessly claims more memory, page by page.

### 2. The Danger: "The VRAM Collision"

There is a massive trap you must avoid. 
If you use dynamic context to keep your KV cache small at startup, you might be tempted to fill all your empty RTX 5070 Ti VRAM with model layers (to make the model faster). 

**The Problem:** If you load 14 GB of model layers into your 16 GB GPU, you only leave 2 GB of breathing room. As your conversation grows, the dynamic KV cache will expand. The moment your context cache needs 2.1 GB, it will collide with the model layers, resulting in a hard **Out of Memory (OOM) crash**.

### 3. The Best Setup: CPU Spillover & Context Shifting

To safely use dynamic context growth without crashing your system mid-conversation, you should combine two specific strategies:

#### Strategy A: Paged KV Cache with CPU Spillover

Engines like `vLLM` or advanced builds of `llama.cpp` allow you to set your DDR5 system RAM as a secondary overflow tank for the KV cache.
* **How it works:** You let the KV cache grow dynamically inside your GPU's VRAM. Once your GPU VRAM hits 99% capacity, the engine automatically starts "evicting" the oldest context pages to your 64 GB of system RAM via the PCIe bus.
* **The Result:** You get blazing fast generation for the recent parts of your conversation (which stay on the GPU), while the older parts of your massive 128K context are safely housed in your DDR5 RAM without crashing your system.

#### Strategy B: Context Shifting (Rolling Window)

If you do not want to deal with RAM spillover, you can enable **Context Shifting**. 
* **How it works:** You set a hard VRAM limit for your dynamic context (e.g., "Grow dynamically, but stop at 8 GB"). When you hit that limit, the engine does not crash. Instead, it drops the oldest 10% of your conversation (excluding your initial system prompt/instructions) and smoothly shifts the rest of the memory down.
* **The Result:** You get an "infinite" chat that automatically cleans up its own oldest memories to protect your hardware.

### How to configure this in your software:

If you are using **Ollama** or **LM Studio**:
1. **Set `num_ctx` to your maximum desired size:** (e.g., 128000). Modern Ollama handles dynamic growth natively.
2. **Enable `flash_attn`:** This automatically optimizes how these dynamic memory blocks are managed on your Blackwell-architecture tensor cores. 
3. **Use Context Shifting:** In LM Studio or Ollama, ensure "Context Shifting" or "Rolling Context" is checked. This guarantees that if your dynamic growth ever exceeds your physical hardware limits, the engine will gracefully drop old tokens instead of crashing. 

If you are using **vLLM** (best for pure performance):
* Use the flag `--enable-prefix-caching` and `--swap-space 16` (This tells the engine it is allowed to dynamically swap 16 GB of old context pages back into your system DDR5 RAM when the GPU gets full).

---

## Persistent Session Memory

> [!NOTE] Prompt
> 
> Is Qwen3.6-35B-A3B suitable for implementing session memory like SOTA LLMs perhaps by perfomring separate calls for history summarization or something?

Yes, **Qwen3.6-35B-A3B** is exceptionally well-suited for implementing persistent session memory (often called "infinite memory" or agentic memory). In fact, because of its specific architecture and your hardware setup, it is actually *better* at this than many larger dense models.

Your instinct to use separate calls for history summarization is spot on. This is how State-of-the-Art (SOTA) frameworks like **MemGPT** or **Zep** handle infinite context. 

Here is exactly why this model excels at session memory and how you can implement it on your RTX 5070 Ti.

### 1. Why Qwen3.6-35B-A3B is Perfect for Background Memory

Implementing session memory requires the engine to constantly read, evaluate, and summarize past conversations. 
* **The MoE Advantage:** Because this model only activates **3 Billion parameters** per token, inference is highly computationally efficient. Your RTX 5070 Ti can easily process a background summarization task at 80+ tokens per second while you are reading its previous reply.
* **The DeltaNet Architecture Advantage:** You are using a hybrid attention model. The "Gated DeltaNet" component of Qwen3.6 is a form of linear attention. Unlike standard Transformers that must keep every single token in memory, linear attention inherently compresses past information into a fixed-size "hidden state" (similar to how old RNNs worked). This makes the model uniquely capable of holding onto the *semantic meaning* of a session even when exact tokens are summarized or dropped.

### 2. How to Implement it on Your Hardware

To get SOTA-level session memory, you should use a multi-tiered memory system. Because you have 64 GB of system RAM, you have plenty of room to run the necessary background services.

#### Tier 1: Working Memory (The standard context window)

You keep your active conversation in the dynamic 128K KV cache we discussed earlier. This gives the model flawless, immediate recall of the current session.

#### Tier 2: The "Background Summarization" Call (Your idea)

As the conversation grows, you don't want the KV cache to reach its limit and drop important early details. You implement an async background loop:
1. **The Trigger:** Every time the active context hits a certain threshold (e.g., 8,000 tokens), your backend triggers a silent, secondary API call to the *same* Qwen model loaded in your memory.
2. **The Prompt:** You send it the oldest 4,000 tokens with a strict system prompt: *"Extract the key facts, user preferences, and unresolved code snippets from this log. Output as a concise JSON list."*
3. **The Injection:** You take that JSON output and dynamically inject it into the main System Prompt for all future active chat calls. 
*Because your backend (like vLLM or Ollama) supports continuous batching, it can handle this background summarization call on your GPU without interrupting your active chat.*

#### Tier 3: Long-Term Episodic Memory (Vector RAG)

For true SOTA memory (remembering a script you wrote 3 weeks ago), summarization isn't enough. You need a **Vector Database**.
1. **The Embedding Model:** Alongside Qwen, you run a tiny, highly efficient embedding model (like `nomic-embed-text-v1.5` or `bge-m3`). These take up less than 1 GB of your system RAM.
2. **The Process:** Every time you finish a chat session, your script chunks the conversation and sends it to the embedding model, storing the vectors in a lightweight local database like **ChromaDB** or **Qdrant**.
3. **The Retrieval:** When you start a new session tomorrow and say, *"Hey, can we update that Python script from last week?"*, your interface instantly searches the Vector DB, retrieves the exact context, and secretly pastes it into Qwen's active KV cache before it generates its first word.

### 3. The "State-Passing" Trick (Bleeding Edge)

Because of the model's DeltaNet architecture, developers in the open-source community are using a feature called **KV-State Serialization**.

Instead of just saving text summaries, you can literally tell your engine to take the 12 GB KV Cache from your current session and **save it to your NVMe SSD as a file** when you close the app. 
When you open the app a week later, the engine streams that 12 GB cache back from the SSD straight into your RTX 5070 Ti. Qwen3.6 will pick up the conversation with the exact same train of thought, reasoning state, and context as if no time had passed at all. No summarization required.

### Recommended Stack to Build This:

You do not need to code this entirely from scratch. You can use existing open-source agent frameworks designed specifically for this:
* **MemGPT:** The gold standard for doing exactly what you suggested. It creates an "OS" for the LLM, giving it tools to page memory in and out of its own context window dynamically.
* **SillyTavern or Open WebUI:** Both of these frontends have built-in Vector DB and background summarization features that you can toggle on with a single click, allowing Qwen to summarize its own history in the background.

---

## Windows 11 LTSC

> [!NOTE] Prompt
> 
> Now, can I practically run all of this on Windows 11 LTSC?

**Yes, not only can you run this entire setup practically on Windows 11 LTSC, it is arguably the best possible Windows OS for local AI.**

Windows 11 LTSC (Long-Term Servicing Channel) strips out Cortana, Copilot, telemetry, widget boards, and background consumer bloatware. For your specific goal—running a heavy 35B parameter model that aggressively utilizes system RAM—this gives you a massive advantage. 

Standard Windows 11 can eat up to 6–8 GB of your system RAM just idling. Windows 11 LTSC typically idles around **2–3 GB**. That gives you an extra 5 GB of your 64 GB DDR5 purely for model weights or KV cache spillover.

Here is exactly how you practically deploy this SOTA stack on Windows 11 LTSC.

### 1. The Native vs. WSL2 Route

You have two ways to run the backend on LTSC. You should choose based on how advanced you want to get with features like PagedAttention and Flash Attention.

**Option A: Fully Native Windows (Easiest)**
* **Tools:** Ollama, LM Studio, or KoboldCPP.
* **Pros:** Just download the `.exe` and run. They have native Windows CUDA support and will handle the 4-bit/8-bit KV cache splitting automatically if you configure the flags.
* **Cons:** Compiling the absolute bleeding-edge versions of **Flash Attention** natively on Windows is notoriously difficult. Without it, processing a massive 128K context prompt will be slightly slower.

**Option B: Windows Subsystem for Linux (WSL2) (Highly Recommended)**
* **Tools:** vLLM, Docker (for ChromaDB/Qdrant).
* **Why it's better:** SOTA AI engines are built for Linux first. WSL2 on Windows 11 LTSC gives you a native Ubuntu kernel with direct, bare-metal access to your RTX 5070 Ti and your 64 GB of DDR5.
* **The Setup:** Because LTSC doesn't have the Microsoft Store, you just open an Admin PowerShell and run `wsl --install`. This installs Ubuntu. You then install the Linux version of CUDA inside WSL2. Now you can run `vLLM` natively, which has the best dynamic KV cache paging and Flash Attention support in the industry.

### 2. Setting Up the Agentic Stack on LTSC

To implement the background summarization, session memory, and Vector RAG we discussed, here is the exact software architecture you should run on your LTSC machine:

* **The Engine (Backend):** Run **Ollama** (Windows native) or **vLLM** (via WSL2). This sits in the background, holding Qwen3.6-35B-A3B in your 5070 Ti and DDR5 RAM, acting as a local server (usually on `localhost:11434` or `8000`).
* **The Memory Database:** Install **Docker Desktop** (or just run Docker engine directly in WSL2). Pull the lightweight image for **ChromaDB**. It will run silently in the background, using practically zero CPU and minimal RAM, waiting to store your Vector RAG embeddings.
* **The Frontend / Agent Manager:** Install **Open WebUI** or run **MemGPT**. These connect directly to your local backend. 
    * In Open WebUI, there is a dedicated settings page for "Memory" where you can enable the Vector DB connection.
    * It also has a built-in toggle for "Continuous History Summarization," which will trigger those background Tier 2 memory calls automatically.

### 3. Practical LTSC "Gotchas" to Watch Out For

Because Windows 11 LTSC is designed for enterprise machines (like ATM interfaces or medical equipment), you have to do a few things manually that standard Windows does for you:

1. **Hardware-Accelerated GPU Scheduling (HAGS):** You *must* ensure HAGS is turned on in your Windows Graphics settings. This allows Windows to effectively manage the heavy PCIe traffic between your 5070 Ti's VRAM and your 64 GB DDR5 during model layer offloading.
2. **Windows Terminal:** LTSC does not come with the modern Windows Terminal. You will want to download it manually (via the `winget` command or GitHub) because you will be managing multiple backend terminal windows (one for the AI engine, one for the Python agent).
3. **High-Performance Power Plan:** By default, Windows aggressively parks CPU cores to save power. Because your DDR5 memory speeds rely heavily on your CPU's memory controller, go into the legacy Control Panel and set your power plan to "Ultimate Performance." This ensures your DDR5 stays locked at 6 GHz when fetching those 8-bit model weights.

**Summary:** 
Windows 11 LTSC is actually the secret weapon for this build. It stays out of your way, doesn't interrupt your background summarization loops with telemetry spikes, and maximizes your available DDR5 RAM. By pairing it with WSL2 for the backend engine and Docker for your vector database, you will have a workstation-grade local AI agent that outperforms standard Windows 11 setups.
