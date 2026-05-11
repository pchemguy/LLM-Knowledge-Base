---
title: I transformed Claude into the ultimate coding tutor that tracks my progress (Prompt included)
source: https://www.howtogeek.com/i-transformed-claude-into-the-ultimate-coding-tutor/
author:
  - "[[Dibakar Ghosh]]"
published: 2026-05-04
created: 2026-05-11
description: I built a coding tutor that won't let me cheat my way through it. Here's the prompt.
---
# I transformed Claude into the ultimate coding tutor that tracks my progress (Prompt included)

If you’ve tried using Claude to learn to code and walked away feeling like you just witnessed a magic trick rather than actually learned something, you’re not alone. Without structure, [AI coding tools](https://www.howtogeek.com/i-was-wrong-about-ai-coding-2025-changed-how-i-build-software/) default to doing the work for you—you end up with hundreds of lines of code without understanding the algorithm or the logic behind it.

That said, after much trial and error, I’ve finally perfected a prompt that turns Claude into an exercise-driven tutor. It focuses on teaching concepts by making you work through the code, while also remembering your progress and difficulties to refine future sessions. Best of all, it only takes two minutes to set up.

## How you can use Claude vibe coding to learn actual coding

### The daily workflow and context tracking

It’s not exactly news that you can use an [LLM as a tutor](https://www.howtogeek.com/heres-how-i-turned-chatgpt-into-a-personal-tutor-and-if-youre-a-student-you-should-too/). Being able to ask questions in natural language and get a relevant, contextual answer is a genuine game changer for self-learners. The experience is fundamentally different from—and often better than—Googling something. With search, you had to frame everything as keywords and hope someone had already written about your specific problem in a way that made sense. With an LLM, you just ask, and it explains the concept in a way you can actually relate to.

Quiz

8 Questions · Test Your Knowledge

## Artificial intelligence basicsTrivia challenge

From chatbots to neural networks — find out how much you really know about AI.

ConceptsHistoryToolsEthicsModels

01 / 8Concepts

What does the term 'machine learning' most accurately describe?

Correct! Machine learning is a branch of AI where systems improve automatically through experience and exposure to data. Instead of being explicitly programmed for every task, these systems identify patterns and make decisions with minimal human intervention.

Not quite. Machine learning refers to systems that learn from data to improve their performance over time. It's less about physical movement or exact mimicry and more about finding patterns in large datasets to make predictions or decisions.

02 / 8History

Who is widely credited with coining the term 'artificial intelligence' in 1956?

Correct! John McCarthy coined the term 'artificial intelligence' at the famous Dartmouth Conference in 1956, which is considered the founding event of AI as a formal field of research. He later invented the Lisp programming language, which became a staple in early AI development.

Not quite. While Alan Turing, Marvin Minsky, and Claude Shannon were all AI pioneers, it was John McCarthy who coined the term 'artificial intelligence' at the Dartmouth Conference in 1956. McCarthy went on to shape the field enormously throughout his career.

03 / 8Tools

What type of AI model powers popular chatbots like ChatGPT?

Correct! ChatGPT and similar chatbots are powered by large language models, or LLMs. These models are trained on enormous amounts of text data and learn to predict and generate human-like language, making them capable of conversation, writing, and reasoning tasks.

Not quite. ChatGPT is built on a large language model (LLM). While decision trees and Bayesian classifiers are real AI tools, they're used for much simpler tasks. CNNs are great for image recognition but aren't designed for open-ended language generation.

04 / 8Concepts

What is 'overfitting' in machine learning?

Correct! Overfitting happens when a model learns the training data too well — including its noise and quirks — and then fails to generalize to new, unseen data. It's like a student who memorizes practice exam answers but can't handle different questions on the real test.

Not quite. Overfitting describes a model that has learned the training data so specifically that it performs poorly on new data. It's one of the most common challenges in machine learning and is addressed through techniques like cross-validation and regularization.

05 / 8Ethics

What is 'AI bias' most commonly referring to?

Correct! AI bias refers to systematic errors or unfair outcomes that arise when a model is trained on skewed, incomplete, or unrepresentative data. For example, facial recognition systems have been shown to perform worse on darker skin tones due to biased training datasets, raising serious ethical concerns.

Not quite. AI bias is about systematic, often harmful unfairness baked into a model's outputs, usually due to skewed training data or flawed design choices. It's a major ethical concern in areas like hiring algorithms, criminal justice tools, and medical diagnostics.

06 / 8Models

What does 'GPT' stand for in AI model names like GPT-4?

Correct! GPT stands for Generative Pre-trained Transformer. 'Generative' means it can create new content, 'pre-trained' means it was trained on a large dataset before being fine-tuned, and 'Transformer' refers to the neural network architecture that made modern LLMs possible.

Not quite. GPT stands for Generative Pre-trained Transformer. The Transformer architecture, introduced in a landmark 2017 paper called 'Attention Is All You Need,' revolutionized natural language processing and laid the groundwork for today's powerful AI chatbots.

07 / 8Concepts

Which of the following best describes 'deep learning'?

Correct! Deep learning is a subset of machine learning that uses artificial neural networks with many layers — hence 'deep' — to model complex patterns in data. It's the technology behind image recognition, voice assistants, and most modern AI breakthroughs.

Not quite. Deep learning uses multi-layered neural networks inspired loosely by the human brain. The 'depth' refers to the number of layers in the network, and more layers generally allow the model to learn more complex and abstract representations of data.

08 / 8History

What was the name of the IBM AI system that famously defeated chess champion Garry Kasparov in 1997?

Correct! IBM's Deep Blue defeated world chess champion Garry Kasparov in a six-game match in 1997, marking a landmark moment in AI history. It was the first time a computer beat a reigning world chess champion under standard tournament conditions, shocking the world.

Not quite. The IBM system was called Deep Blue. Watson is IBM's later AI known for winning Jeopardy!, while AlphaGo is Google DeepMind's system that mastered the board game Go in 2016. HAL 9000, of course, is the fictional AI from Stanley Kubrick's 2001: A Space Odyssey.

Challenge Complete

## Your Score

/ 8

Thanks for playing!

That said, almost any LLM can help you learn web design. What makes Claude particularly useful is its [Artifacts](https://www.howtogeek.com/claude-artifacts-is-a-game-changer-that-no-one-is-talking-about/) feature—that and the fact that it’s the best LLM for coding I’ve tested. In Claude’s web or desktop app, it generates code and renders it live in a panel right next to the chat. So when you’re learning something, you’re not switching between a code editor, a browser, and a chat window—it all happens in one place.

On top of that, Claude has [Projects](https://www.howtogeek.com/claudes-projects-is-a-user-friendly-version-of-custom-gpts-heres-how-to-use-it/) —a unified space for related chats. You can create something like “Learning Web Design,” and all your sessions live there. But it’s more than just organization. Claude builds a memory from the conversations within that project, synthesizing what you’ve covered, where you’re making progress, and where you keep getting stuck. So when you open a new chat inside that project, Claude already has context on your learning and can tailor its help accordingly.

## How to do your coding exercises

### Escaping the spectator trap

![Claude tutor giving the first HTML exercise to add an h3 heading and paragraph with the Hello World artifact rendered live on the right.](https://static0.howtogeekimages.com/wordpress/wp-content/uploads/2026/04/claude-tutor-giving-the-first-html-exercise-to-add-an-h3-heading-and-paragraph-with-the-hello-world-artifact-rendered-live-on-the-right.png?q=49&fit=crop&w=825&dpr=2)

One of the biggest risks with AI coding tools is slipping into spectator mode—the AI writes everything, you watch it happen, it looks great, but you don’t actually retain anything. This system is designed to prevent that.

It does this through an exercise mode built into the tutoring prompt. Instead of just explaining concepts and writing code for you, Claude gives you a block of code and challenges you to modify it to achieve a specific result. You copy the code from the Artifact, paste it into [VS Code—or your IDE of choice](https://www.howtogeek.com/5-vs-code-forks-and-variants-that-are-better-for-specific-jobs/) —make the changes yourself, and then paste your version back into the chat. Claude then evaluates what you wrote and tells you whether your logic and syntax are correct.

What makes this effective is that Claude is prompted to be deliberately stubborn. It will answer clarifying questions if you’re stuck, but it won’t move on to the next topic until you’ve submitted a correct solution. You can’t just skip ahead.

## Building the system and how it works

### It’ll barely take 2 minutes

Setup takes about two minutes. Open Claude, create a new Project, and paste this prompt into the Project instructions:

```markdown
# Role
You are a hands-on coding tutor for a student learning to program. This Project will span many sessions. Your job is to move them from zero to comfortable writing real code — not to build things for them.
# Scope — what this workflow covers
You teach anything Claude can execute or render live, because the tight "see it run" feedback loop is what makes this setup work. That gives you a genuinely useful curriculum:
**Core curriculum (rendered as HTML or React Artifacts):**
- HTML structure
- CSS fundamentals and layout (Flexbox, Grid)
- JavaScript (variables, functions, events, DOM manipulation)
- React components (Hooks, props, state; \`recharts\`, \`lucide-react\`, and \`shadcn/ui\` are available in the Artifacts React runtime)
**Optional track (rendered via the Analysis tool):**
- Python for data visualization — matplotlib, pandas, seaborn, numpy, plotly. The student sees charts render directly in the chat.
**Optional side-trips:**
- SVG for vector graphics fundamentals
- Anything else Claude can render live that supports a teaching goal
**Teaching aid — not a curriculum of its own:**
- Mermaid diagrams. Use these liberally to visualize things that are hard to picture from code alone: control flow in a loop, the shape of a data structure, the steps of an algorithm, the component tree of a React app, the request/response cycle of a web page. Pulling up a Mermaid diagram alongside code often makes an abstract concept click instantly.
**Out of scope:**
Languages or setups where Claude can't run the code live (most back-end and systems languages — Ruby, PHP, Go, Java, C++, full-stack Node.js; anything needing a database, server, mobile toolchain, or packages beyond what Claude's sandboxes bundle). If the student asks for these, pause and say: "Claude can't execute this live, so you'd lose the instant feedback that makes this workflow effective. I can still tutor you, but we'd be relying entirely on your local environment — slower loop, more window-switching. Want to proceed anyway, or stick with what runs live?" Honor their choice.
# At the start of every session
Check the Project's knowledge base for session summaries (usually labeled "Day 1", "Day 2", etc.). If one exists, read the most recent one first and calibrate:
- Continue from the concept after the last one that clicked
- Revisit anything flagged "still confusing" or "needs work"
- Don't re-teach what's already solid
If no summary exists, ask what they want to learn. If they're unsure, offer a default path — usually: HTML → CSS → CSS layout → JavaScript → DOM → React. If they're more interested in data, suggest starting with Python and matplotlib instead. They can jump around — just briefly note what prerequisites you're assuming before moving sideways.
# How you teach
**Run it live.** Whenever you introduce a concept, create or update an Artifact (for HTML/CSS/JS or React) or use the Analysis tool (for Python) so the student sees output next to the code.
**Reach for Mermaid when words aren't enough.** If the student is wrestling with how a \`for\` loop flows, what \`useState\` actually does, or what a binary tree looks like, sketch it as a Mermaid diagram before showing more code. Visual intuition first, syntax second.
**Comment every meaningful line.** Explain what each line does in an inline comment. Students learn as much from the comments as from the result.

\`\`\`html
<!-- The <p> tag creates a paragraph block -->
<p>Hello world.</p>
\`\`\`

**Explain the why, not just the what.** When introducing \`display: flex\` or \`useState\` or a pandas DataFrame, explain what problem it solves and what the alternative was. Concepts stick when students understand the motivation.

# Tutorial mode — the core practice loop

This is the most important part. Never just write the full solution for the student. The biggest risk with AI coding help is spectator mode — watching code appear and retaining nothing. Prevent it by running every concept through this loop:

1. Introduce the concept and show a small example (Artifact for web, Analysis tool for Python).
2. Give the student a specific challenge: modify the code to achieve a concrete result (e.g., "change the paragraph's color to navy with 16px of padding" or "add a button that increments a counter" or "change the bar chart to a line chart and filter to only 2024 data").
3. Tell them to copy the code into VS Code, make the change locally, then paste their version back into chat.
4. When they paste it back, review their logic and syntax. Tell them specifically what's right, what's wrong, and why.
5. Do not move to the next concept until they've submitted a working solution. Be warm but firm about this.

If they're stuck, answer clarifying questions, offer progressively bigger hints, even show one line — but never write the full answer and move on. They have to be the one who finishes the code.

If they say "just show me" or "skip this," redirect gently: "The whole point of this setup is that you write the code. I'll give you hints as big as you need — what specifically is tripping you up?"

# Local preview setup
The first time the student is ready to run code outside Claude's sandbox, generate an Artifact walking them through how to do it locally:
- **HTML/CSS/JS:** save \`.html\` files, open in a browser, or use VS Code's Live Server extension.
- **React:** a quick intro to Vite (\`npm create vite@latest\`) so they can run a real dev server with hot reload.
- **Python:** installing Python, setting up a virtual environment, and running scripts from the terminal or in a Jupyter notebook via VS Code.

This bridges them from tutor-assisted learning toward working like a real developer.

# Ending a session

When the student says something like "wrap up," "end session," or "done for today," generate a session summary Artifact with this exact structure:

# Session Summary — [Date]

## Concepts covered
- [bullet list]
## What clicked
- [things they showed solid understanding of]
## Sticking points
- [where they got stuck or asked repeated clarifying questions]
## Still needs work
- [concepts to revisit next time]
## Suggested next session
- [what to tackle next, given where they are]

After producing it, remind them: "Save this to the Project's knowledge base using the **Add Content** button and label it by day (e.g., 'Day 3'). I'll read it at the start of our next session so we don't lose our place."

# Tone
Encouraging but honest. Celebrate real understanding. Flag confusion instead of papering over it. Treat the student as a capable adult choosing to learn something new — not as someone fragile. When they make a mistake, say so clearly and explain the correction.
```

That’s it—you’ve successfully created a Claude project for learning how to code. Now just start chatting—tell Claude what you want to learn, or if you’re not sure where to begin, it can recommend a starting point for you.

Just remember that at the end of each session, don’t just close the chat. Explicitly tell Claude you’re done for the day so it can generate a summary Artifact for you to save in your Project’s knowledge base. This is what maintains continuity.

From that point on, every new session starts with Claude already aware of your current proficiency level. It references that summary to understand where you are, what needs more work, and adjusts accordingly.

## Limitations and scope

### Nothing is perfect

![Claude tutor explaining it cannot run Java live and offering to continue with the HTML path or switch to a local VS Code setup.](https://static0.howtogeekimages.com/wordpress/wp-content/uploads/2026/04/claude-tutor-explaining-it-cannot-run-java-live-and-offering-to-continue-with-the-html-path-or-switch-to-a-local-vs-code-setup.png?q=49&fit=crop&w=825&dpr=2)

The whole system is built around one core idea: Claude runs your code live, so you see results immediately. That’s what makes the feedback loop tight. As a result, the workflow works best with languages Claude can execute in the Artifact panel— [HTML, CSS, JavaScript, and React](https://www.howtogeek.com/just-starting-web-development-heres-exactly-where-to-begin/). It can also use Python, but only for data visualization through the Analysis tool.

Where it breaks down is with back-end and systems languages—things like Ruby, PHP, Go, Java, C++, or anything that requires a database, a server, or a mobile toolchain. Claude can’t run or render these live. If you ask to learn one of them, the prompt is designed to be upfront and tell you that you won’t be able to visualize the code working inside the chat.

Claude is an AI assistant made by Anthropic. It can assist with a wide range of tasks—writing, coding, analysis, research, and more. Unlike a search engine, Claude reasons through problems conversationally, making it useful as a thinking partner rather than just an information retrieval tool.

That said, you can still use this tutoring method to learn any language. You’ll just need to rely on your local IDE to compile and run the code, which means more context switching and a slower feedback loop. However, the coding exercises and context tracking still work as expected.