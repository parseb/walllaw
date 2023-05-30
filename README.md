[![Foundry][foundry-badge]][foundry]

[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg


______

<b>Problem</b> <br>
DAOs are failing, forward, but still, failing. Most of the old guard is not doing too well. (DXdao, Aragon, etc.) Others are mostly permissioned (multisigs), governed by other entities (foundations) or too dense for the light to intuitively get in (Maker). Principal agent problems, mismanagement, failure at equitably recognizing and retaining contributors are some of the issues that plague the space. Carrot on side, some of the innovators and most experienced of proposal driven governance actors have rugged themselves. It is clear, the ever-present default, proposals, are not it. <br>

<b>Solution</b> <br>
Disincentivised, anarchic, execution agnostic, continuous governance. Possibly the first maximally decentralised and economically coherent DAO structure.

WalllaW is a Decentralised Organization type that instrumentalizes fungibility to facilitate fully trustless and explainable collective efforts. It accomplishes this primarily by means of three low-complexity devices: membership, majority vote and inflation.

WalllaWs are a type of DAO where DAOs are composed agents constituted for enacting change. Such an agent is considered both decentralised and autonomous only if it can initiate and execute actions without systematically depending on the consent or input of any one atomic party. Notionally, this exigence applies to its processes as well.

<b>Design Assumptions</b>
An organisation is a membrane that moves forward. This, “organisation”, necessitates determinations of belonging and inter-subjectivity within a systematising order.

<b>Membrane</b>. An organ that employs binary determinations to separate between in and out. A good way to think about it are access badges. All access badges constitute an organisation’s membrane. WalllaW membranes are a list of tokens and required balances. Maintaining membership depends on satisfying these criteria. Membranes are versatile, can be hardened, loosened or used to define specialised organs or autonomous sub-sections.

<b>No movement without energy</b>. Directed energy expenditure is a precondition for any forward. Energy is fungible, convertible, divisible and storable. Can be concentrated or diluted. Can be measured and transferred and most importantly, can explain power relations. In WalllaWs, energy expenditures take the form of local fungible token allocations that settle to a central, still fungible, store of value. This consolidates anarchic local movements into discernible unitary agents.

<b>Governance costs</b>. Changing direction expends energy. The need for governance should be strong enough to justify the energy expenditure. WalllaWs by default, have no treasuries, no top-down budgets and no semi-permanent governance supervising staff. They replace all of that with belonging criteria and fungibility operations. This amounts to a minimum viable structure, non-prescriptive about sense-making and without central points of failure.

<b>Efficient Markets</b>. Dis-incentivised governance participation will arguably cut the noise and the performative participation out. Will also focus the voice of those that are invested in the future of the DAO and who are likely to be so to the extent to which they consider it necessary. That said, there is no reason, nor need to participate in governance unless you are willing to sacrifice time, effort or token value in advance to the shared benefit of all other token holders. In that sense, the inactive tokenholder is in the optimal position for maximizing value extraction. Freeriding is the expected role for most token holders. It is also expected of token holders to sell if the DAO is under-governed to the degree it endangers the value accrual or the utility of the token or, for them to alternatively start a competing structure.

<b>Why no proposals</b> <br><br>
And this is the key reason and possibly the most obvious differentiator between WalllaWs and any other DAO structure I know of. WalllaWs do not use proposals. Not by default and importantly not as a one-size fits all vehicle for consensus, recognition and redistribution.

A big problem with proposals is that they have hidden costs that increase exponentially with size. Governance forums are akin to ad-hoc parliaments, delegates are representatives, discussions are public consultations, and proposals, laws. Looks like it works, the familiar sights of government at work are emitted. But this is a tragedy. This highly skeuomorphic default is irrevocably tethered to paper based bureaucratic primitives. This limits what a DAO can be and renders much of the current experimentation useless.

Internet native organisations should look more like networks than parliaments. This insistence on proposals as the only viable form governance can take disables the agility of digital value. It also tends to almost universally demand of humans to seek approval to contribute. In my view the DAO concept implies permissionless contribution. Doing the work instead of writing proposals as to how one day in three months time, approval given, you will start the work would be in many ways an improvement. Retroactive, or an in context, symbolic “cool idea, look forward to see how this will shapes up; here’s a potential $1 over a year”, gesture, funding, would also be an improvement. To summarize, proposals are skeuomorphic, paper era nostalgic devices, they externalize costs to participants (writers, but more importantly, readers) and unnecessarily condition recognition and redistribution. They inevitably reproduce the same bureaucratic devices: delegates, representatives, budgets, supervisors, etc. and are in my view, as one would have figured by now, the root of all DAO evils. When intentions are clear, prefaces are not needed.

<b>Core Structural Component</b> <br><br>
There are four types of building blocks that in the current implementation are deployed through the same function, three of which reuse the same DAOinstance contract. The base instance, which is expected to act as the main entry port that custodies the entire balance of the root value token (RVT). SubDAOs which are the same, the difference being their Base Value Token (BVT, RVT for instance) is also the Internal Value Token of their immediate parent. Lastly, endpoints, of which there are two types. The first is the same as the above with the difference being that they have only one member and their only purpose is to act as a sink for rewarding individual agents in local contexts. The second type and the only one that does not use the DAOinstance contract is a (gnosis) safe endpoint. This multisig can be initiated as needed, by a member, with all the members of the parent instance as owners. All safe default rules and capabilities apply. Its purpose is to address any arbitrary needs or uncertainties.

<b>Majoritarian Pluralism</b><br><br>
WalllaWs relies on majoritarian decision making. However, since they do not have textually articulated proposals, all latent changes are broadly speaking up to vote at all times. There’s two main types of fungible token votes in all instances. First, a vote to change the in-use, enforceable, membrane. Second, a vote to change the annual inflation rate, or, for consistency: speed of movement. These changes enter in effect when a simple majority is reached. An agent can express multiple preferences which stay dormant until triggered by a simple majority; these altogether paint a range of politically feasible states that add to predictability.

The pluralism part is that any member of any entity can deploy a sub-entity with arbitrary conditional access of their choosing. The membrane can be defined in such a way as to create uncensorable autonomous zones free from token holder dominance. It as such grants space for plurality of expression within existing contexts. The result is that affirming the need for novel or controversial direction cannot be censored by the majority. Sure, the big bad whales can meet behind big bad doors to coordinate as to change the membrane and kick out the initiator from higher-level participation, but they cannot eject the initiative body or prevent members from allocating resources to it. Crucially, being ousted by means of membrane redefinition from the higher levels does not affect one’s ability to keep their gained or deposited fair share on exit as deposit and withdrawal operations do not depend in any way on membership.

The fact that membranes can be changed and autonomous zones can be created is of nature as to foster sufficient flexibility in order to accommodate and containerize specialized external work or cross-dao collaborations. This all arguably gives minorities a good shot at protecting their interests. Afterall, there is no exclusivity anywhere it the system. The root value token can be used by an unlimited number of DAOs. So, any minority interest can always exit and/or instantiate their own. Totally separate organisations will compete for the same value pool or coordinate around specific opportunities such as up-cycling proposal driven entities that use the same token.

<b>Fungibility and Inflation</b><br><br>
I mentioned fungibility and inflation a lot above but did not explain their purpose. I will repeat, it is important: energy is fungible. WalllaWs function on the basis of permissionless energy allocations. So, if you want to govern, you have to pay. The innovation here is pay to govern, or rather govern by paying. An equally viable approach, if you want to govern and not only do you want so but importantly need to, is to govern by working. The latter, if done successfully might suffice as income. To summarise. Energy is fungible. Moving anything in any direction necessarily involves an energy expenditure. The movers can start moving at their own cost in hopes of retroactive peer or outcome compensation. They can stop and start so on whatever they want, whenever they want to, but it is not unreasonable to assume that volunteering has its limits and suitable payment will accelerate desired change.

WalllaWs have one requirement. They need at the time of initiation to be provided with a value base under the form of an ERC20 token. The in protocol deposited such tokens, referred to hereafter as Root Value Token (RVT), are the fuel that powers the organisation. All redistributed value eventually settle back to it. The fuel is metabolised to energy, used for movement and eventually converted back to RVT exchangeable value to be leveraged in the external economy. The direct subject of redistribution however is not RVT but its corresponding Internal Value Token(s) (IVT). Each WalllaW has at least one IVT. The relationship is as follows: an IVT can be minted in exchange for a Root Value token. This is true for the core unit entity that settles all RVT withdrawals. The relationship is 1-to-1 as one RVT will always get one IVT. The same is true across all instances irrespective of their level. But there’s a catch. Rather two of them. First, one’s entity IVT is their descendant’s Base Value Token (BVT). BVT is the exact same as RVT, but as the name implies, it does stand as a base of value, but only for higher level zones, and not for the structure in its entirety. All BVTs and IVTs settle as, and can be priced in, the originating RVT.

The second catch is what I have so far mentioned in passing: inflation. Inflation determines the speed at which energy is expended, income issued, or to keep the metaphor going: is the metabolic speed. This anarchically governed issuance is also not unlike state run deficit. It primarily functions as a self-regulatory mechanism but also tempers the risks associated with token governance as it renders “classical attacks” unprofitable. The reason being that internal tokens, inflation over time given, are always in greater numbers than their underlying base. The depositors can swap IVT back to BVT and eventually RVT, however, this operation will always incur a loss as internal tokens act on withdrawal, as shares, and, inflation over time given, 1 IVT < 1 BVT. This is how everything is paid for. Internal tokens are Wrappers on deposit at t0 and shares on withdrawal at t+1. The difference of value, captured through inflation, is the totality of what the movers, shakers and producers are paid with.

<b>Sense-making</b><br><br>
In the digital, but more so in fully transparent and deterministic environments: ‘action produces information’. Trust or uniquely identifying traits are not central in markets, transport or any systematising, expectedly deterministic order. What programmable blockchains can do is be a canvas that makes it possible for any operating logic to be encoded as a finite bell-curved range of possibilities which lends itself to habitual summary. And having been endowed with a view as to what is in the interest of the collective and individual, as well as information about the latest actions and future likelihoods, one can eventually instinctually project and continuously adapt to outcomes more efficiently. Firms where all actors are owners and can to different but known degrees directly influence the distribution of resources and the story it tells about itself are possible. This is how this kind of ship is steered: for each level or independent body an inflation rate is operationalised. Like interest rates in the economy, but decided on directly by taxpayers to the known, quantitative degree to which they pay taxes.

This is the global view. The local picture is foundationally composed out of the same two pieces as in the case of all other instances: inflation and membrane. Inflation, metabolic speed, or rate of value distribution as compensation for past or future effort. The membrane, as the in or out descriptive and deterministic boundary which will likely drive the experience of being in as it will likely point agents to locally relevant means such as gated tools, work-spaces and communication channels.

Back to action produces information, there is a wide range of likely relevant types of signal. One is the preference profile of co-members. The extent to which one’s allocations coincide with personal gain will likely matter. The extent to which different agents’ preferences coincide over time is also likely to matter. This overall results in sybil-indiferent yet context relevant identity in the sense that internal allocations are semi-fungible: it does matter who makes the allocation. In some instances, particularly for new initiatives, small, symbolic allocations are likely to become norm. Conversely, the reduction of a particular preferred flow by an attention worthy agent will likely become a shelling point for critical engagement on the merits and future of specific efforts or directions. This altogether, hypothetically being able to evaluate an anarchically constituted organization by just glancing at a network graph depicting value flows is, I would argue, quite a big deal.

<b>Neutrality and Collusion</b><br><br>
Essentially, a mechanism is credibly neutral if just by looking at the mechanism’s design, it is easy to see that the mechanism does not discriminate for or against any specific people. The mechanism treats everyone fairly, to the extent that it’s possible to treat people fairly in a world where everyone’s capabilities and needs are so different.

WalllaWs are neutral to the degree the underlying value base is. Fungible things, in general, are neutral. Their distribution and embedded logic fully convey their potential for equitable outcomes. Nothing can compete with known inter-dependent quantities as generalizable vehicles for describing state of affairs and their potential. And, since most of the WalllaW made available actions impact resource distributions, and there is no choice but to “put your money where your mouth is”, intentions are hard to hide. This helps not only with collusion resistance but also with self-awareness and generalizable benchmarks. And, since the overall philosophy is “pay to govern” and all movement is redistributive by nature, it is unlikely for bribes or any other such economic attacks to hold much sway as they can succeed only for a limited time and only by the attacker incurring economic loss to the benefit of all other members.

<b>Limitations</b><br><br>
Since the speed at which energy reaches its point of consumption depends on inflation rates along the path, all questions pertaining to when and if something will happen are constantly renegotiated. Also, there is no default execution engine. What, how and if execution occurs is left up to the distributors as “value is in the eye of the beholder”. WalllaWs do not have fixed inflection points, milestones, KPIs or exclusive roles. At least not by default. Legitimacy and authority will tend to be conjunctural, to loosely follow the money and its corresponding narratives.

Lastly, it is unknown at this time who are the many potential operators that are at home in this perceived uncertainty. It will, if at all, initially be adequate mostly for open source software development as a way for these sparse and multi-interested communities to finance and prioritise work as well as for any of the other more smarmy and permissionless activities. Grant programmes are also likely a well fitting immediate use case.
<br><br><br><br>

______________________________

# WalllaW


A <b>Decentralized Internet Organization</b> framework that instrumentalizes fungibility to facilitate access to fully trustless and explainable collective efforts. It primarily accomplishes this by means of three low-complexity devices: inflation, majority vote and membership.

### DIO?

Decentralized Internet Organisations are anarchically constituted <b>membranes that move</b> towards a continuously defined forward.<br>

Self-replicates, uses "guild.xyz"-like authorisation and coordinape-like circles to determine its identity and direct its energy. No proposals.

## How does it work


### Membrane

The membrane determines if an agent is within or outside the organisation. It is constituted out of a list of tokens and balances and, provided an agent satisfies them as eligibility conditions, associated with a membership token. The membership token gives one access to all internal functionality of that specific entity and it can be revoked through the fault of the possessor or change in eligibility conditions. Each sub-DAO instance is independent in its determinations of membership. As such external specialised work or other DAOs can be appended. The membrane is expected to link to metadata such as social media communication channels or membership-gated workspaces. 

<img src="https://user-images.githubusercontent.com/5999852/216822881-9f3ca3e9-5091-46da-af81-2d42e2715d0c.png" width="100%">
<br>

### Movement

Movement occurs through agent-driven initiative and retroactive, contiguous allocation of resources. Resource allocation is a feedback mechanism. Whether taking the form of a separate working space (subDAO) or within an existing one, insufficient allocations for or dwindling support in favour of other, potentially more pressing efforts, is to be interpreted as feedback reflecting on the work in context. Initiating movement or calibrating energy allocations is primarily available only to members. Local power is proportional with an agent's stake.



<img src="https://user-images.githubusercontent.com/5999852/216976509-c860f8d0-5799-4a36-9345-a6d706f5e340.png" width="100%">
<br>

### Value Flow

<img src="https://user-images.githubusercontent.com/5999852/216985884-d163eb6f-f375-405b-ae6f-7d3a99d907fe.png" width="100%">
<br>



### Pluralism and Versatility

Majority vote driven governance is not known for granting much room to emergent, novel, potentially destabilising diversities of expression. While the base decision mechanisms for the definition of an existing space (membrane and identity changes) within walllaw relies on circumstantial majorities, the right to create new autonomous spaces within contexts is bound by simple membership. It is as such likely for a type of 'majoritarian pluralism' to be the norm given that the parameters one can use to define what constitutes a majority are boundless.
<br><br>
The layout formed by the ways in which value quite literally trickles down might be of concern. I will not be able to stress this enough, but, any such space has the capacity to perform almost any arbitrary action an ethereum account can. That means, among other things, that a sub-DAO can at any point migrate outside the field of gravity of its incubating parent. [...] While this opens the door to a very wide range of security concerns, it is nonetheless a capability worth fighting for. Time delays, or more creative protection mechanisms can work to this end.
<br><br>

A hypothetical example of versatility: 5% MKR$ owners create an instance for the purpose of running experiments that do not find their place within the core organisation. They do their thing, but also retain their ability to vote as a block within the original, dominating governance process. One aspect worth entertaining here is what happens when such a block vote becomes decisive. What walllaw means for dissent and coalition building given that preferred resource allocations highlight the operating ideology of agents should also be considered.




### Anticapture

#### Economic Resilience

There's a set of beliefs and assumptions that grounds the security model of walllaw. Among those is that "DAOs are for uncommon shared interests". As such, DAO governance, participating in it, is not for profit but for the advancement of said shared interest. It follows that it not only can but also logically should operate at a loss. In walllaw there is no direct economic benefit for purely formal participation. Quite the contrary. 

While capital deposits do increase one's swaying power, they do so at economic cost due to inflation. You not only get let’s say, .9 of same token value, but also likely provide an advantageous exit opportunity for others given that any new deposit is a deflationary event. Governance costs and one ought to participate in governance only if they believe their input is valuable to the extent they are willing to sacrifice economic value to make themselves heard. And that should by no means be controversial. There is a cost to you reading this as there is a cost to keeping up with interminable chains of opinions and proposals. Governance is for those that care enough to accept some economic downside for the future progress to be brought upon the collective through their input. For all others, holding the token should be good enough.



#### Social Resilience

Membranes are what primarily defines the identity of a (sub)DAO. A membrane can change and a member can find itself outside of it. Member or not, they are entitled and can access their legitimately gained share of capital. Members can coordinate outside of pure majoritarian consensus and migrate and legitimise another entity in the face of attacks. A closing of rank of sorts. And the cool thing about it is that just as well as it can reconfigure for immune purposes so it can for merging or cross-DAO coordination simply by  using the same membrane id.

<br>
<br>

(a diagram I did but does not really belong elsewhere)
![Screenshot 2023-05-26 115344](https://github.com/parseb/fungido/assets/5999852/1f5ebb93-9b1f-4573-baf0-b8d34d699edc)

##### Disclaimer
<i>These smart contracts are being provided as is. No guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of the user interface or the smart contracts. They have not been audited and as such there can be no assurance they will work as intended, and users may experience delays, failures, errors, omissions, loss of transmitted information or loss of funds. The creators are not liable for any of the foregoing. Users should proceed with caution and use at their own risk.</i>
