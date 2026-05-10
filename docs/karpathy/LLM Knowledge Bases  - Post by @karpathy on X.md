---
title: LLM Knowledge Bases  - Post by @karpathy on X.md
source: https://x.com/karpathy/status/2039805659525644595
author:
  - "@karpathy"
published: 2026-04-02
created: 2026-05-10
description: LLM Knowledge Bases Something I am finding very useful recently - using LLMs to build personal knowledge bases for various topics of research
---

LLM Knowledge Bases

Something I'm finding very useful recently: using LLMs to build personal knowledge bases for various topics of research interest. In this way, a large fraction of my recent token throughput is going less into manipulating code, and more into manipulating knowledge (stored as markdown and images). The latest LLMs are quite good at it. So:

Data ingest:

I index source documents (articles, papers, repos, datasets, images, etc.) into a raw/ directory, then I use an LLM to incrementally "compile" a wiki, which is just a collection of .md files in a directory structure. The wiki includes summaries of all the data in raw/, backlinks, and then it categorizes data into concepts, writes articles for them, and links them all. To convert web articles into .md files I like to use the Obsidian Web Clipper extension, and then I also use a hotkey to download all the related images to local so that my LLM can easily reference them.

IDE:

I use Obsidian as the IDE "frontend" where I can view the raw data, the the compiled wiki, and the derived visualizations. Important to note that the LLM writes and maintains all of the data of the wiki, I rarely touch it directly. I've played with a few Obsidian plugins to render and view data in other ways (e.g. Marp for slides).

Q&A:

Where things get interesting is that once your wiki is big enough (e.g. mine on some recent research is ~100 articles and ~400K words), you can ask your LLM agent all kinds of complex questions against the wiki, and it will go off, research the answers, etc. I thought I had to reach for fancy RAG, but the LLM has been pretty good about auto-maintaining index files and brief summaries of all the documents and it reads all the important related data fairly easily at this ~small scale.

Output:

Instead of getting answers in text/terminal, I like to have it render markdown files for me, or slide shows (Marp format), or matplotlib images, all of which I then view again in Obsidian. You can imagine many other visual output formats depending on the query. Often, I end up "filing" the outputs back into the wiki to enhance it for further queries. So my own explorations and queries always "add up" in the knowledge base.

Linting:

I've run some LLM "health checks" over the wiki to e.g. find inconsistent data, impute missing data (with web searchers), find interesting connections for new article candidates, etc., to incrementally clean up the wiki and enhance its overall data integrity. The LLMs are quite good at suggesting further questions to ask and look into.

Extra tools:

I find myself developing additional tools to process the data, e.g. I vibe coded a small and naive search engine over the wiki, which I both use directly (in a web ui), but more often I want to hand it off to an LLM via CLI as a tool for larger queries.

Further explorations:

As the repo grows, the natural desire is to also think about synthetic data generation + finetuning to have your LLM "know" the data in its weights instead of just context windows.

TLDR: raw data from a given number of sources is collected, then compiled by an LLM into a .md wiki, then operated on by various CLIs by the LLM to do Q&A and to incrementally enhance the wiki, and all of it viewable in Obsidian. You rarely ever write or edit the wiki manually, it's the domain of the LLM. I think there is room here for an incredible new product instead of a hacky collection of scripts.

---

## Comments

> **Goss Gowtham 𝕏 @Goss\_Gowtham** · [2026-04-02](https://x.com/Goss_Gowtham/status/2039830480829456596)
> 
> Can you make a video of how you work with md files, agentic IDEs?
> 
> Your earlier explanations of using LLMs were really helpful.
> 
> > **Andrej Karpathy @karpathy** · [2026-04-02](https://x.com/karpathy/status/2039832291464417746)
> > 
> > I was just thinking the same thing

> **Gavriel Cohen @Gavriel\_Cohen** · [2026-04-02](https://x.com/Gavriel_Cohen/status/2039810935452225959)
> 
> Can you share more on the incremental compilation?
> 
> I've found that if processing one by one, they don't have enough context to understand how to divide to directories.
> 
> Is there an optimal batch size? Multiple stages?
> 
> > **Andrej Karpathy @karpathy** · [2026-04-02](https://x.com/karpathy/status/2039812403962253744)
> > 
> > Atm it's not a fully autonomous process, I add every source manually, one by one and I am in the loop, especially in early stages. After a while, the LLMs "gets" the pattern and the marginal document is a lot easier, I just say "file this new doc to our wiki: (path)".

> **jiahao @\_\_endif** · [2026-04-02](https://x.com/__endif/status/2039810651120705569)
> 
> you are like Linus to Linux now, the meta vibe coder, I wonder how many projects will be created overnight because of your tweet
> 
> > **Andrej Karpathy @karpathy** · [2026-04-02](https://x.com/karpathy/status/2039816150062948769)
> > 
> > Haha I vibe code products with twitter :D

> **Krishna Tammireddy @tammireddy** · [2026-04-02](https://x.com/tammireddy/status/2039814328229204201)
> 
> Every business has a raw/ directory.
> 
> Nobody's ever compiled it.
> 
> That's the product.
> 
> > **Andrej Karpathy @karpathy** · [2026-04-02](https://x.com/karpathy/status/2039814446479192187)
> > 
> > Might be an LLM reply I don't know, but yes exactly.

> **CBir @c\_\_bir** · [2026-04-02](https://x.com/c__bir/status/2039812841750839506)
> 
> are you useing obsidian cli?
> 
> > **Andrej Karpathy @karpathy** · [2026-04-02](https://x.com/karpathy/status/2039814066575917263)
> > 
> > Currently no because I'm trying to keep it super simple and flat, it's just a nested directory of .md files and .png files and a few .csv and .py, and the schema is kept up to date in AGENTS.md . The LLMs get this very easily. Any custom functions are easy to vibe code tools for.