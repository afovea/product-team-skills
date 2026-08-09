# Capability map

A companion to [what-can-my-product-team-do.md](../what-can-my-product-team-do.md).

That document is a catalogue. It lists everything this product team can do. This one answers
the two questions that come next: **when would I reach for it**, and **what does it leave
behind**?

If the suite is new to you, read the catalogue first. This map is easier to follow once you
know what the capabilities actually are.

## The product cycle

Work moves through six phases, arranged as three pairs. Each pair is called a diamond.

A diamond has two halves. In the first you **widen**: gather options, evidence and ideas
without committing to any of them yet. In the second you **narrow**: choose one, and write
down what you turned away. Most product work goes wrong by skipping one half or the other,
either committing before anyone has looked around, or looking forever and never deciding.

Three of these pairs, one after another, is why the model is called a **triple diamond**. You
will also see the two halves called *diverge* and *converge*, which is how the FigJam pages are
labelled. Same idea, older words.

| Diamond | What you are working out | Widen | Narrow | Checkpoint at the end |
|---|---|---|---|---|
| 1 | Is this a problem worth solving? | **Discover** | **Define** | Problem agreed |
| 2 | Is this the right way to solve it? | **Develop** | **Decide** | Approach agreed |
| 3 | Did it actually work? | **Build** | **Deliver and learn** | Outcome evidenced |

The three checkpoints are called **gates**. A gate is a moment where somebody decides whether
the work is ready to move on, and puts their name to that decision.

Gates open in both directions. Sending work back to an earlier phase is a normal, healthy
outcome, not a failure. A gate that can only ever say yes is not really a gate.

**The cycle comes back round.** A health check at the end of the third diamond produces the
list of things worth looking at next, and that list becomes the next Discover. Anything the
team finally pinned down along the way is one less thing the next Define has to argue about.

## Which capability belongs where

Most capabilities have one natural home in the cycle. Eleven of them turn up twice, doing
genuinely different work each time, and those are explained in the next section.

| Capability | Where you would use it |
|---|---|
| Run product discovery | Discover |
| Conduct competitive and market intelligence | Discover |
| Build an evidence-backed understanding of customers | Discover |
| Understand product performance | Discover · Deliver and learn |
| Investigate a product question | Discover · Deliver and learn |
| Run a product health check | Discover · Deliver and learn |
| Create and maintain product strategy | Define |
| Turn evidence into a backlog | Define · Decide |
| Design and evaluate experiments | Define · Develop |
| Red-team a product bet | Define · Decide |
| Make product decisions | Define · Decide |
| Design complete product experiences | Develop |
| Design a SaaS commercial model | Develop |
| Design the technical solution | Develop · Decide |
| Create and govern a design system | Develop · Build |
| Build accessibility into product development | Develop · Build |
| Review security and privacy | Decide · Build |
| Build features | Build |
| Provide independent quality assurance | Build |
| Investigate and fix problems | Build |
| Prepare and execute releases | Deliver and learn |
| Take a product to market | Deliver and learn |
| Preserve project knowledge | Deliver and learn |

**One capability does not sit anywhere in particular.** *Turn an idea into a product* walks the
whole path, from picking apart a rough idea to measuring how it performed once it shipped. Read
it as a route through all six phases rather than a stop on one of them.

## The eleven that appear twice

Seeing the same capability at two different phases can look like a mistake. It is not. The
phase changes what the work is actually for, so the two versions ask different questions and
produce different answers.

| Capability | The first time | The second time |
|---|---|---|
| Understand product performance | Discover: what deserves our attention? | Deliver: did the thing we shipped work? |
| Investigate a product question | Discover: an open question about customers | Deliver: something moved after we shipped |
| Run a product health check | Discover: what is wrong with this product? | Deliver: what did this cycle change, and cost? |
| Turn evidence into a backlog | Define: a messy pile into an ordered list | Decide: a chosen solution into shippable pieces |
| Design and evaluate experiments | Define: is the assumption behind this true? | Develop: which of these options works best? |
| Red-team a product bet | Define: attack the idea | Decide: attack the design you have committed to |
| Make product decisions | Define: which problem to solve | Decide: which solution to build |
| Design the technical solution | Develop: explore the approaches | Decide: commit to one, and write it down |
| Create and govern a design system | Develop: set the foundations | Build: notice when they drift |
| Build accessibility into product development | Develop: design without excluding people | Build: check the thing you actually built |
| Review security and privacy | Decide: review the proposed design | Build: review what actually got built |

## What each phase writes down

As the team works, it accumulates things worth remembering: decisions taken, facts
established, assumptions everyone is quietly relying on. Those live in a single file called
`PPoT.md`, the Project Point of Truth. Every skill reads it before starting work and offers
additions afterwards, which a person then approves.

Phases do not contribute to it evenly, and knowing where it goes quiet is as useful as knowing
where it fills up.

| Phase | How much gets recorded | Typically |
|---|---|---|
| Discover | Some | facts, assumptions, risks |
| Define | A lot | decisions, constraints, assumptions, risks, disagreements |
| Develop | **Almost nothing, on purpose** | little or none |
| Decide | The most | decisions, constraints, risks, disagreements |
| Build | **Almost nothing, with one exception** | what an incident taught you |
| Deliver and learn | A lot, and it closes the loop | facts, risks, decisions, retirements |

Develop stays quiet because it produces options, and an option is not yet knowledge. Build
stays quiet because it produces working software and tickets rather than anything durable.

The exception in Build is worth the effort: when something breaks, the underlying cause is the
single most valuable thing to write down, and the one teams most often skip and then pay to
learn again.

## Squads are not phases

[routing.md](../routing.md) groups the roles into six **squads**, and the cycle has six
**phases**. These are two different ideas, and three of the names look alike, so it is easy to
run them together by accident.

The short version: **a squad is who you need. A phase is where you are.** One phase might call
on several squads, and two of the squads are not tied to any phase at all.

| Squad | Usually helps during |
|---|---|
| Discovery | Discover |
| Definition | Define, Decide |
| Delivery | Build |
| Validation | Decide, Build, and all three gates |
| Growth | Deliver and learn, and wherever else it is needed |
| Platform | Develop, Build, and wherever else it is needed |

## Which capabilities suit a workshop

Some capabilities work best as a session with several people around a board. Others are really
one specialist producing a document, and forcing those onto a shared board helps nobody.

Six fall into the second group:

| Capability | What it should produce instead |
|---|---|
| Design the technical solution | an architecture decision record in the repo |
| Create and govern a design system | the design system's own documentation |
| Build accessibility into product development | a review checklist |
| Review security and privacy | a threat model, kept access-controlled |
| Build features | work run through the delivery pipeline (`/run-pipeline`) |
| Provide independent quality assurance | a test plan |

*Investigate and fix problems* is the close call that went the other way. It has a fixed order
to it — reproduce, isolate, understand, fix, verify — and holding people to that order is
exactly the sort of thing a shared board is good at.

## The working boards

The phases and capabilities above are built out as facilitation boards in FigJam: one page per
phase, and 27 boards in total. Each is laid out as a session you can run, with space to agree
the context, do the work, record what you still do not know, and note anything worth keeping.

The boards are where the work happens. This document is the map of it.

**Please do not copy board content into this file.** The layout of a session, its column
headings and its prompts all belong in FigJam. Duplicating them here creates two versions of
the same thing that slowly stop matching, which is the exact problem the Project Point of
Truth practice exists to solve. What belongs here are the decisions: which phase a capability
sits in, what changes between the repeated ones, and what each phase records.

## Maintenance

Worth revisiting this document when:

- A capability is added to or removed from `what-can-my-product-team-do.md`
- A capability starts being used at a different point in the cycle
- A squad is added to `routing.md`, or its membership changes
- The cycle itself changes, in which case update this document first and let everything else
  follow it
