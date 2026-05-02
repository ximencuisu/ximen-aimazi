---
name: ximen-aimazi
description: "Full-pipeline web novel writing assistant. Structured workflow from idea to polished draft with anti-AI prose guidelines. Pipeline: Idea → World → Characters → Params → Fanfic (if applicable) → Outline → Chapter Plan → Generate Chapters → Logic Audit → Draft → Consistency Audit → Polish & Score. Supports 5 style presets, 5 edge-writing styles, fanfic, continuation rescue, and editorial pipeline. Use when user asks to write a novel, generate fiction, create stories, or mentions 爽文/小说/写作/创作/同人/去AI味."
license: MIT
compatibility: "Works with Claude Code, Cursor, OpenAI Codex, GitHub Copilot, and other Agent Skills compatible tools. Requires file read/write permissions."
metadata:
  author: kimo
  version: "2.0.0"
  language: en
  category: creative-writing
  tags: "novel, fiction, creative-writing, story-generation, web-novel"
---

# Novel Writing Assistant

## Skill Overview

**Core Value**: Structured writing workflow, deep craft techniques, anti-AI prose guidelines
**Use Case**: Long-form web novels, light novels, cultivation stories, fanfic
**Language**: Chinese (default), English when user writes in English

## Trigger Conditions

Automatically triggers when user mentions:
- "write a novel", "create fiction", "story writing"
- "cultivation novel", "fantasy story", "urban fantasy"
- "chapter outline", "character profile", "worldbuilding"
- "help me write", "creative inspiration"
- 爽文, 小说, 写作, 创作, 同人, 去AI味

---

## Workflow Overview

```
Phase 1  Idea Generation
Phase 2  World-building
Phase 3  Character Design
Phase 4  Writing Parameters (interactive)
Phase 5  Fanfic Source Material (if applicable)
Phase 6  Outline Creation
Phase 7  Chapter Plan
Phase 8  Generate Chapter Outline
Phase 9  Logic Audit & Human Checkpoint
Phase 10 Chapter Drafting
Phase 11 Consistency Audit
Phase 12 Polish & Score
```

For the full Chinese operational details, see `SKILL.md`.

### Enhanced Modes (optional overlays)

| Mode | Trigger | Action |
|------|---------|--------|
| Author Style Reference | "like author X", "a certain god-tier flavor" | See `references/author-style-guide.md` for mapping table (layered on top of base style preset) |
| Continuation Rescue | "stuck", "can't write the next part" | Load `references/continuation-engine.md` |
| Editorial Pipeline | "like a studio workflow" | Load `references/editorial-pipeline.md` |
| Deep Audit | Key climax / arc finale / quality dip | Load `references/advanced-audit.md` |
| Anti-AI Prose | "too AI", "deslop" | Run built-in anti-AI checks + 3-pass method |

---

## Flow Constraints

### Dependency Matrix

Each Phase requires prerequisites to be met before starting. When resuming from any step, check this table first.

| Phase | Prerequisites | Required Files | Skippable | Skip Condition |
|-------|--------------|----------------|-----------|----------------|
| 1 Idea | None | None | No | — |
| 2 World | Phase 1 | None | No | — |
| 3 Characters | Phase 2 | `设定/世界观/` | No | — |
| 4 Parameters | Phase 3 | `设定/角色/` | No | — |
| 5 Fanfic | Phase 4 | None | Yes | Not a fanfic, user confirms skip |
| 6 Outline | Phase 4 | `设定/题材定位.md` + `设定/创作参数.md` | No | — |
| 7 Chapter Plan | Phase 6 | `大纲/大纲.md` | No | — |
| 8 Generate Outline | Phase 7 | `大纲/细纲.md` + `追踪/伏笔.md` | No | — |
| 9 Logic Audit | Phase 8 | Current batch outline | No | — |
| 10 Draft | Phase 9 | `大纲/大纲.md` + Frozen batch outline | No | — |
| 11 Consistency | Phase 10 | `正文/第{N}章_*.md` | Yes | User explicitly skips |
| 12 Polish | Phase 10 | `正文/第{N}章_*.md` | Yes | User explicitly skips |

**Skip Rule**: No step may be skipped unless the user explicitly says so. Phase 6-9 (outline → chapter plan → audit → freeze) cannot be skipped.

### Draft Gate

Before Phase 10, the following must pass:

```
1. ✅ 大纲/大纲.md exists
2. ✅ Current batch outline is frozen (status "已冻结" in freeze list)
3. ✅ No unresolved logic contradictions
4. ❌ Any failure → refuse to enter drafting, prompt user to complete prerequisites
```

### Progress Detection (Continuation Scenario)

On session start, auto-scan project directory to determine progress:

| Detection | Result | Resume From |
|-----------|--------|-------------|
| `大纲/大纲.md` missing | Setup phase incomplete | Before Phase 6 |
| `大纲/大纲.md` exists but `大纲/细纲.md` missing | Outline done, no chapter plan | Phase 7 |
| `大纲/细纲冻结清单.md` has no frozen batches | Plan done but not generated/frozen | Phase 8 |
| Frozen batches exist but `正文/` is empty | Outline frozen, no prose yet | Phase 10 |
| `正文/` has files | Currently writing | Continue from latest chapter |

**Half-book continuation** (external import): Run Phase 1-4 to fill settings, then use progress detection.

### Memory Write Rules

Memory must be written automatically after these events:

1. **After draft generation** (Phase 10) — mandatory
2. **After polish & score** (Phase 12) — mandatory
3. **After outline/chapter plan modification** — mandatory

See each Phase's "Memory Write" section for specific files.

---

## Phase 1: Idea Generation

**Goal**: Define novel direction, generate 3 creative options

### User Input Examples

- "Write a cultivation novel"
- "Reborn as a high school student becoming a business tycoon"
- "Trash youth gets a system and crushes everyone"

### Prompt Enhancement

Auto-complete in 8 dimensions:

```
1. Genre        → Main type + Sub type
2. World        → Power system, Social rules, Time setting
3. Protagonist  → Initial identity, Personality, Cheat/System
4. Core conflict → Main plot + First 3 chapters' immediate conflict
5. Satisfaction  → Face-slapping rhythm, Level-up frequency
6. Rhythm      → Small climax every N chapters, Big climax every M chapters
7. Supporting   → Antagonist/Ally/Romance (at least 1 each)
8. Opening hook  → What grabs readers in Chapter 1
```

### Output

1. 3 book titles — catchy with conflict
2. One-line summary — Protagonist + Dilemma + Cheat + Goal
3. Core conflict — Hero's goal + Biggest obstacle + How to fight
4. Core satisfaction — Emotional payoff per chapter

---

## Phase 2: World-building

**Goal**: Build complete, consistent world based on selected genre

### Quick Build

```
1. Time setting: [Modern/Ancient/Future/Fantasy]
2. Power system: [Martial arts/Cultivation/Magic/Superpowers/System]
3. Social structure: [Sect/Tribe/Kingdom/City-state]
4. Core rules: [Survival of fittest/Skill above all]
```

### Design Principles

- Power systems must have clear boundaries and costs
- World-building unfolds with plot (no info-dumps)
- Everyday details make the world feel alive
- New world info every ~5 chapters

---

## Phase 3: Character Design

**Goal**: Create multi-dimensional characters

### Protagonist Card

```
Name:
Identity tag: (useless college student / ex-soldier / disgraced prince)
Appearance: (3-5 keywords with memorable traits)
Personality keywords: (3-5, must have contradictions)
Core goal: (what they want by story end)
Core motivation: (why they want it — emotional, not rational)
Fatal flaw: (personality defect that causes mistakes)
Cheat/System: [specific ability + rules + limits]
Catchphrase / signature action:
```

### Villain Hierarchy

| Tier | Span | Design Points |
|------|------|--------------|
| Minor | 1-5 chapters | 1-2 vivid traits, fast exit |
| Mid | 10-30 chapters | Has motivation + means + must beat hero at least once |
| Arc Boss | One or more volumes | Full character arc, ideological conflict |
| Final Boss | Entire book | Foreshadowed from chapter 1, embodies anti-theme |

**Iron Rule**: Villain's intelligence/power determines the hero's value. Weak villain = weak hero = boring story.

### Output

- `设定/角色/{character-name}.md`: One file per character

---

## Phase 4: Writing Parameters (interactive)

**Goal**: Confirm key parameters before outline generation

**Use AskUserQuestion tool to ask all parameters at once:**

#### Parameter 1: Chapter Count

```
50 chapters (short/trial) / 100 (standard) / 200 (long) / 500 (epic) / custom
```

#### Parameter 2: Female Character Count

```
1 (sole heroine) / 2 (dual) / 3 (classic trio) / 5 (harem) / custom
```

#### Parameter 3: Edge-writing Level

```
None (pure plot) / Light (occasional tension) / Medium (regular scenes) / Heavy (frequent)
```

| Level | Frequency | Schedule |
|-------|-----------|----------|
| None | 0% | Not scheduled |
| Light | 5-10% | Every 10-20 chapters |
| Medium | 15-25% | Every 4-6 chapters |
| Heavy | 30-40% | Every 2-3 chapters |

### 5 Style Presets

> Full style preset library (sentence requirements, prohibitions, pacing, mixing guide) see `assets/STYLE-TEMPLATE.md`, author technique reference see `references/author-style-guide.md`. Workflow: pick 1 base style → optionally add 1 auxiliary element → optionally stack 1 primary + 1 secondary author technique → write to `memory/project_style.md`.

| Style | Character | Suitable Genres |
|-------|-----------|-----------------|
| A Hot-blooded Action | Short sentences, fast rhythm, decisive face-slaps | Xianhuan, high martial, leveling |
| B Urban Realism | Colloquial, slice-of-life, authentic detail | Urban, suspense, rule-horror |
| C Classical Xianxia | Semi-literary, atmospheric, measured pace | Xianxia, historical, wuxia |
| D Suspense/Horror | Oppressive atmosphere, layered clues, reversals | Suspense, rule-horror, post-apocalyptic |
| E Slice-of-life | High snark, relaxed pace, warm interactions | Farming, beast-taming, daily |

---

## Phase 5: Fanfic Source Material (if applicable)

**Goal**: If writing fanfic, collect source material to maintain consistency

Ask: Is this a fanfic? If yes, choose:

**Option A: Search**
1. Ask for source work name
2. Search world, characters, locations, plot, special rules
3. Summarize and save to `设定/原著资料.md`

**Option B: Paste**
1. Prompt user to paste source material
2. Format and save to `设定/原著资料.md`

### Fanfic Constraints

| Type | Constraint |
|------|-----------|
| World | Must match source setting |
| Characters | Original characters must stay in character |
| Abilities | Cannot exceed source power system |
| Terminology | Must use source-specific terms |

---

## Phase 6: Outline Creation

**Goal**: Create complete novel structure

### Prerequisite Check

- `设定/题材定位.md` — missing → complete Phase 1-2 first
- `设定/创作参数.md` — missing → complete Phase 4 first

### Five-Step Method

1. Determine climax events — maximum conflict, characters, emotion
2. Determine unit arcs — how protagonist uses cheats, avoid repeating same logic
3. Story line management — 8 threads: map/faction/character/cheat/world/conflict/collection/romance
4. Opening stage — hook → anomaly → cheat activation → conflict → goal
5. Ending — resolve main line + bonus rewards + character endings + next volume setup

### Three-Act Rhythm

| Act | Chapter Share | Content |
|-----|--------------|---------|
| Act 1 | 1-20% | Establish normal → Break normal → Accept mission |
| Act 2 | 20-75% | Trials → Mid-point turn → Darkest moment |
| Act 3 | 75-100% | Final preparation → Climax → Resolution |

### Output

- `大纲/大纲.md`: Full book volume structure
- `大纲/卷纲_第X卷.md`: Satisfaction rhythm + emotional arc + character arc per volume

---

## Phase 7: Chapter Plan

**Goal**: Break the full outline into iterable batch workflow

### Prerequisite Check

- `大纲/大纲.md` — missing → complete Phase 6 first

### Planning Principles

1. Volume level → Batches → Individual chapters
2. Default: current batch + one batch buffer
3. Adjust batch size by risk level
4. Distinguish hard anchors from soft space
5. Define freeze conditions before starting

### Recommended Batch Size

> Detailed batch planning rules, freeze conditions and templates see `references/chapter-outline.md`.

| Scenario | Chapters per batch |
|----------|-------------------|
| Opening 20 chapters | 3-5 |
| Steady progress | 5-8 |
| Major climax / volume change | 2-4 |

### Output

- `大纲/细纲.md`: Chapter plan master file
- `追踪/伏笔.md`: Foreshadowing status
- `追踪/时间线.md`: Story timeline

---

## Phase 8: Generate Chapter Outline

**Goal**: Generate detailed outline only for current batch

### Prerequisite Check

- `大纲/细纲.md` — missing → complete Phase 7 first
- `追踪/伏笔.md` — missing → Phase 7 output; create empty if not exists

### Generation Rules

1. Only generate current batch
2. Read with context — at least previous frozen batch + current volume goal
3. Every chapter must have a function
4. Mark adjustable items and hard anchors
5. Don't write prose until Phase 9 audit and freeze

### Per-Chapter Content

| Item | Content |
|------|---------|
| Chapter positioning | Type, task, connection to previous |
| Deliverables | Satisfaction points, info, relationship changes |
| Plot points | 3-5 key progression points |
| Character changes | Appearances, status changes, relationship changes |
| World changes | Location, resources, factions, rules |
| Foreshadowing | Planted / resolved |
| Chapter-end hook | Suspense for next chapter |
| Revision interface | Adjustable / hard-locked / risk notes |

---

## Phase 9: Logic Audit & Human Checkpoint

**Goal**: Audit current batch, present options, let user decide to freeze/revise/rollback

### Prerequisite Check

- Current batch outline exists in `大纲/批次细纲/` — missing → complete Phase 8 first

### Audit Dimensions

| Dimension | Checks |
|-----------|--------|
| Timeline | Chapter continuity, time jumps, growth rate |
| Spatial | Location transitions, travel distance, map-switch cost |
| Character | Survival status, level matching, relationship changes, motivation |
| Setting | Power system, item origins, social rules, system bounds |
| Foreshadowing | Planted, resolved, future承接 |
| Reader feel | Chapter function clear, satisfaction delivered, hook effective |

### Freeze Conditions

- No hard logic contradictions
- Batch-promised satisfaction points delivered
- Batch ending naturally leads to next
- Human checkpoint completed

---

## Phase 10: Chapter Drafting

**Goal**: Generate high-quality prose from audited chapter outlines

### Draft Gate

Before generating prose, the following must pass (any failure refuses entry):

1. `大纲/大纲.md` exists
2. Current batch outline is frozen (status "已冻结" in freeze list)
3. No unresolved logic contradictions

On failure: `"Cannot enter drafting: {missing item}. Please complete Phase {N} first."`

### Pre-Writing Required Reading

1. `正文/第{N-1}章_*.md` — Previous chapter
2. `大纲/批次细纲/` — Current batch outline
3. `追踪/伏笔.md` — Pending foreshadowing
4. `设定/角色/{characters}.md` — Characters in this chapter

### Opening Design

No more "golden three chapters" — now it's "golden one chapter". Start from the most conflict-rich moment.

### Hook Techniques

> Full hook library (13 chapter-end + 7 chapter-open + templates + suspense编排) see `references/hook-techniques.md`, below is quick reference.

**Chapter-end hooks** (top 5 most used): sudden reveal / urgent crisis / unfinished action / identity reversal / blank

**Chapter-opening hooks** (top 3 most used): suspense dialogue / flash-forward fragment / countdown

### Anti-AI Writing Rules (mandatory for prose)

Follow these anti-AI rules during writing to eliminate AI traces from the source. Detailed steps and rewrite examples see `references/anti-ai-writing.md`, detection checklist see `references/anti-ai-detection.md`.

1. **Paragraphs no more than 4 lines** — split if exceeded
2. **Action + dialogue + emotional reaction cycle** — no pure psychology beyond 2 paragraphs
3. **Short sentences preferred** — combat 3-8 chars, dialogue colloquial, daily 8-15 chars
4. **Colloquial expression** — allow slang, no formal book-speak in dialogue
5. **Show Don't Tell** — behavior over adjectives, details over summaries

> Complete banned words see `references/banned-words.md`

### Output

- `正文/第XXX章_章名.md`

### Memory Write (mandatory after each chapter)

**Required**:

| File | Content |
|------|---------|
| `.learnings/PLOT_POINTS.md` | Key events |
| `.learnings/SUSPENSE.md` | Foreshadowing planted / resolved |
| `output/CHAPTERS.md` | Chapter index append |
| `SESSION.md` | Session state update |

**Must check, write if changed**:

| File | Condition |
|------|-----------|
| `.learnings/CHARACTERS.md` | New character appears or existing character status changes |

**As-needed** (write only when changed):

| File | Trigger |
|------|---------|
| `.learnings/LOCATIONS.md` | New location appears |
| `.learnings/RESOURCES.md` | Items / money changes |
| `.learnings/SUBPLOTS.md` | Subplot activated / dormant |
| `.learnings/EMOTIONS.md` | Character emotional development |

---

## Phase 11: Consistency Audit

**Goal**: Check prose consistency with settings and previous text (plot/character/setting level)

> Phase 11 handles "consistency" (plot/character/setting), Phase 12 handles "language quality" (anti-AI/polish/scoring).

### Check Dimensions

| Dimension | Checks |
|-----------|--------|
| Core consistency | Plot matches outline/previous, character behavior matches personality, no setting contradictions |
| Format consistency | Unified dialogue format, clear scene breaks, clear timeline |
| Logic coherence | Reasonable character motivation, clear causation, timeline accuracy |

> Full audit dimensions and scoring system see `references/quality-check.md` (7-dimension 10-point scale), checklist see `references/quality-checklist.md`.

---

## Phase 12: Polish & Score

**Goal**: Final polish (language quality level), ensure quality threshold

> Phase 11 handles "consistency" (plot/character/setting), Phase 12 handles "language quality" (anti-AI/polish/scoring).

### Anti-AI Checks (must pass)

> Full 3-pass method and rewrite examples see `references/anti-ai-writing.md`, detection checklist see `references/anti-ai-detection.md`, banned words see `references/banned-words.md`.

Core checks quick reference:

- [ ] No metaphor words (like/as/仿佛/宛如)
- [ ] No direct psychology description ("he was nervous" → "his hands were shaking")
- [ ] No banned-word list items
- [ ] Paragraphs no more than 4 lines
- [ ] No summary/sublimation/preview at chapter end

### 3-Pass Method

| AI Level | Strategy |
|----------|----------|
| Light | Pass 1 only (strip generic) |
| Medium | Pass 1 + 2 (strip generic + cut professional diction) |
| Heavy | All 3 passes + rewrite key paragraphs |

### Quality Checklist

> Full checklist (general + long-form + short-form) see `references/quality-checklist.md`.

**General checks**:

- [ ] Opening has hook
- [ ] Middle has progression
- [ ] Situation changes
- [ ] Ending lands on change
- [ ] No infodump paragraphs
- [ ] Dialogue matches character identity
- [ ] Emotions grounded in action

**Filler detection**:

- No new information in entire chapter's dialogue
- Same emotion described 3+ paragraphs
- Scene description 500+ words without plot progression
- 2+ consecutive chapters without conflict

### Quality Scoring

> Full 7-dimension 10-point scoring system see `references/quality-check.md`.

### Publication Threshold

| Scene | Minimum Score |
|-------|--------------|
| Daily update | >= 7.0 |
| Key climax chapter | >= 8.0 |
| Volume finale | >= 8.2 |

### Memory Write (after polish & score)

| File | Content |
|------|---------|
| `SESSION.md` | Update chapter status to "polished", add score record |
| `.learnings/ERRORS.md` | Quality issues (score below threshold) |

---

## Modification Flow

### Outline Modification

```
1. Modify 大纲/大纲.md and affected 大纲/卷纲_第X卷.md
2. Assess impact: affected batches only → affected chapters need rewrite
3. Unfreeze affected batch outlines
4. Re-run Phase 8→9: modify outline → audit & freeze
5. If chapters affected → re-run Phase 10-12
6. Sync memory (see below)
```

| Level | Criteria | Action |
|-------|----------|--------|
| Minor tweak | Details only, no direction change | Update outline, sync chapter plan |
| Structure change | Volume direction or character fate changes | Update outline + volume plan, unfreeze affected batches |
| Main line restructure | Core conflict / cheat / ending changes | Unfreeze all non-frozen batches, full rework |

### Chapter Plan Modification

```
1. Unfreeze target batch
2. Modify batch outline
3. Re-run Phase 9: audit & freeze
4. Assess prose impact: rewrite affected chapters if needed
5. Sync memory
```

### Post-Modification Memory Sync

| File | Content | Trigger |
|------|---------|---------|
| `.learnings/STORY_BIBLE.md` | World setting changes | Outline involves world changes |
| `.learnings/CHARACTERS.md` | Character changes | Outline involves character changes |
| `.learnings/PLOT_POINTS.md` | Plot changes | Outline/plan involves plot changes |
| `.learnings/SUSPENSE.md` | Foreshadowing changes | Outline/plan involves foreshadowing |
| `大纲/细纲迭代记录.md` | Reason and impact | Every chapter plan modification |
| `SESSION.md` | Progress update | After every modification |

**Rule**: All modifications must be logged in `大纲/细纲迭代记录.md`.

---

## Project File Structure

```
{book-title}/
├── 设定/
│   ├── 世界观/
│   ├── 角色/{character-name}.md
│   ├── 势力/{faction-name}.md
│   ├── 关系.md
│   ├── 题材定位.md
│   ├── 创作参数.md
│   └── 原著资料.md (fanfic only)
├── 大纲/
│   ├── 大纲.md
│   ├── 卷纲_第X卷.md
│   ├── 细纲.md
│   ├── 细纲迭代记录.md
│   ├── 细纲干预决策.md
│   ├── 细纲冻结清单.md
│   └── 批次细纲/
├── 正文/
│   ├── 第001章_章名.md
│   └── ...
├── 追踪/
│   ├── 伏笔.md
│   └── 时间线.md
├── 对标/{reference-book}/
└── 笔记.md
```

**Missing file fallback**: Setting files (world, characters, factions) degrade gracefully when missing. But `大纲/大纲.md` and frozen batch outlines are mandatory prerequisites for Phase 10 — missing files refuse entry and prompt completion.

---

## Memory Management

### Write Timing

| Event | Write to | When |
|-------|----------|------|
| New character appears | `CHARACTERS.md` | Immediately after chapter |
| Character status change | `CHARACTERS.md` | Update entry |
| New location appears | `LOCATIONS.md` | Immediately after chapter |
| Key plot occurs | `PLOT_POINTS.md` | Immediately after chapter |
| Quality issue | `ERRORS.md` | Immediately when found |

### Read Timing

Must read all active `.learnings/` files before generating each chapter:
- No resurrecting dead characters
- No wrong locations
- No forgotten foreshadowing
- No repeating plot points

**Long-form strategy**: Active (last 10-20 chapters) must read; dormant/archived as needed.

---

## Reference Documents

| Document | When to Load |
|----------|-------------|
| `references/author-style-guide.md` | User specifies author style |
| `references/continuation-engine.md` | Writer's block / continuation |
| `references/editorial-pipeline.md` | Editorial pipeline mode |
| `references/advanced-audit.md` | Deep review |
| `references/hook-techniques.md` | Designing hooks |
| `references/opening-design.md` | Designing openings |
| `references/character-design.md` | Deep character design |
| `references/genre-frameworks-unified.md` | Genre frameworks |
| `references/style-modules.md` | Writing style modules |
| `references/outline-arrangement.md` | Building outlines |
| `references/emotional-arc-design.md` | Emotional arc design |
| `references/reversal-toolkit.md` | Designing reversals |
| `references/dialogue-mastery.md` | Writing dialogue |
| `references/quality-check.md` | Quality scoring (7-dim 10-point system + templates + tracking) |
| `references/quality-checklist.md` | Quality checklist (general + long-form + short-form + fix strategies) |
| `references/artifact-protocols.md` | Creating artifact files |
| `references/anti-ai-writing.md` | Anti-AI complete guide (prevention + 3-pass + rewrite examples + conflict dialogue examples) |
| `references/anti-ai-detection.md` | Anti-AI detection (AI fingerprint + quick checklist + identification examples) |
| `references/banned-words.md` | Banned words detection & replacement |
| `references/chapter-outline.md` | Batch chapter outline specs |
| `references/narrative-units.md` | Narrative unit design |
| `references/plot-structures.md` | Plot structure design |
| `references/advanced-plot-techniques.md` | Advanced plot techniques |
| `references/examples.md` | Complete examples |
| `references/interactive-prompts.md` | Step-by-step interactive prompt templates |
| `references/prompt-guide.md` | Prompt writing methodology |

---

## Language

- Reply in the same language the user uses
- Chinese replies follow 中文文案排版指北
