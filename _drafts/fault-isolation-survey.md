---
layout: blog_post
title: A Survey of Fault Diagnosis
categories: [research]
scholar:
    bibliography: isolation_survey.bib
---

## Part 1

Our goal is to isolate the type of fault that manifests in a task execution, which is part of a broader fault management process that often encompasses the following steps:


- \textit{Fault Forecasting}: Involves using knowledge of the system from specified models or from experts to anticipate the faults that are likely to occur and develop mitigation strategies for them. The step is often a requirement for standards compliance~{% cite Guiochet2017 %}.

- \textit{Fault Detection}: Involves detecting the presence of any deviation from the norm (faults) in the robot or system. There is a lot of work this problem~{% cite Chandola2009 %}.

- \textit{Fault Isolation}: Attempts to determine the type of the fault~{% cite Trave-Massuyes2014 %}. This is our goal. Isolation can be a simple classification or can be carried out through an iterated process of \textit{troubleshooting}~{% cite Chen2017 %}.

- \textit{Fault Identification}: Process of determining the taxonomy and consequences of the fault. It is often the product of fault forecasting, but can also be the result of model-based simulations. Identification is often key for the growing field of \textit{condition-based monitoring}~{% cite jahnke2015machine %}.

- \textit{Fault Recovery}: The step(s) of removing the fault or taking actions to mitigate its effects~{% cite Crestani2015 %}. In the realm of condition-based monitoring, recovery could include a simple maintenance activity rather than the amelioration of a specific fault.


We focus on isolation,FOOTNOTE:To make my life easier in matching the terminology used in specific papers, I will use \textit{diagnosis} interchangeably with isolation from here on out, although the term diagnosis has been used in the literature to refer to the detection and identification processes as well.} but note that the methods discussed are often informed by aspects of the entire management process described above; hence the overview so far.

\medskip

There are two approaches to fault isolation~{% cite Reiter1987 %}:

- \textit{Diagnosis through experience}, which relies upon heuristics obtained through past experience or human expertise to infer the faults and their causes given observations of the system. Such diagnosis is \textit{Knowledge-based} or \textit{Data-driven} depending on the source of the heuristics {% cite Pettersson2005 Khalastchi2018a %}.
- \textit{Diagnosis from first principles}, which aims to find conflicts between the observations of a system and the expectations of it under a given a formal description of the system or its behaviour. Such an approach is called \textit{Model-based} diagnosis~{% cite Trave-Massuyes2014 %}.

Data-driven and knowledge-based methods are often used as tools within the model-based diagnosis process (as explained later), but they can sometimes be used independently of the model-based diagnosis too. We first examine the works that use these methods  outside the context of model-based diagnosis.

Knowledge-based approaches augment human knowledge into the diagnosis process:

-  As described by {% cite Pettersson2005 Khalastchi2018a %}, they accomplish the goal by using experts to:

    - specify simpler models of the system
    - specify heuristics to isolate faults given multiple anomaly detectors
    - provide diagnosis feedback in order to construct expert systems


- {% cite Zhi-JieZhou2013 %} develop an method to track the hidden fault state of an executing system based on rules applied to observed system signals. The rules and their relative importance could be specified by experts, but the authors' method relearned the importance of the rules from experience. The authors contend that their approach is preferable in situations where both qualitative knowledge of the system and quantitative data from the system are available.

- Among the methods used to gather expert input, fault forecasting using FMEA, FTA, etc. are principled, but tedious, methods~{% cite Guiochet2017 %}.

- Knowledge-based approaches are generally able to adequately trade-off the need for human specification (a drawback of model-based approaches) with diagnostic performance in the face of noisy data (a drawback of data-driven approaches).

- They generally cannot detect unknown faults~{% cite Khalastchi2018a %}.

- Our modeling assumptions will be informed by human expertise, but we aim to improve upon expert-specified models with more data, as was the case with {% cite Zhi-JieZhou2013 %}.


Purely data-driven approaches to fault isolation try to learn associations between the system or its behaviours and the faults that can manifest over time, without the presence of a formal system model:

- These methods are often used for anomaly detection~\cite{Christensen2008,Hornung2014,Khalastchi2017,Park2018,Chen2018a}. However, there are exceptions:

    - {% cite Pettersson2007 %} train neural networks to classify between two types of faults based on a time series of sensory input.
    - {% cite Chen2011 %} contend that SVMs (after a lot of feature engineering and feature selection) outperform Neural Networks and LDA in an isolation task.FOOTNOTE:I believe these results will not generalize and therefore should be ignored.}
    - {% cite He2013 %} isolate 8 different types of faults using Decision Trees, with the ultimate goal of providing an interpretable diagnosis.
    - {% cite karimi2014comparing %} use an ensemble of MLPs to isolate 21 faults in a complicated manufacturing process. In the process, they introduce a novel metric to use for boosting.
    - {% cite Chine2016 %} perform fault isolation in photovoltaic cells using neural networks in conjunction with human specified rules.
    - {% cite Park2017 %} classify categories of faults in robot-assisted feeding based on sensor signals within time windows.
    - {% cite Pashazadeh2018 %} describe a pipeline consisting of feature extraction, feature selection, and parallel classifiers to provide a multi-classifier approach to fault isolation in wind turbines.


- Fault isolation can also be a matter of detecting changes to an underlying state in a tracked system. Data-driven methods can accomplish this goal by means of change-point detection in time-series data~{% cite Chandola2012 %}:

    - {% cite johnson2013bayesian %} use Hidden Semi-Markov Models for automatic segmentation of time series data. It is an extension of \cite{Fox2008,fox2009sharing}, which have been used in robotics by {% cite Butterfield2010 %} and {% cite Niekum2012 %}.
    - {% cite DAngelo2016 %} use genetic algorithmsFOOTNOTE:Aside: annoyingly, works in FDI (Fault Detection and Isolation) sometimes call GAs "Immune Systems''...} to for change point detection and classification.


- Data-driven methods are also useful for modeling underlying statistics of the monitored process:

    - {% cite Poola2017 %} survey faults in the domain of computational workflows in distributed computing. In particular, they characterize different probability distributions that are often used to predict the likelihood of faults in a workflow under different contexts or assumptions.
    - {% cite Zhang2018a %} try to predict the next time of failure for particular faults in an aircraft's auxiliary power unit by modeling faults as a Renewal Process following a Weibull distribution.


- The strength of data-driven approaches lies in their not needing a system model and in their ability to adapt to unseen situations.

- The drawbacks of data-driven approaches are that they can be sensitive to the quality of the training data, they might require a lot of hard-to-obtain training data (especially for isolation), they can ignore rare faults, and they can be hard to train for isolation, especially if there are many classes of faults or if some faults are unknown.FOOTNOTE:Both conditions are frequently true in the real-world.}

- We will be using data-driven means to reduce the specification burden on humans.


Model-based diagnosis approaches (MBD) relies on the (tedious) specification of a system model, or a behaviour model, as a prerequisite for fault isolation.

-  There are two popular approaches to MBD depending on how the models are specified~{% cite Trave-Massuyes2014 %}

    - Specifying the model as first-order logic fluents---practitioners form what is called \textit{DX} community

    - A fault is diagnosed by examining the conflict set of the logical fluents between the logic specification of the system model, and the observed behaviour of the system, which is also expressed in first-order logic {% cite Reiter1987 Gossler2015 %}.
    - {% cite steinbauer2005detecting Gspandl2012 Zaman2013 %} have used this method for robot fault isolation, with {% cite Zaman2013 %} also having released a publicly available ROS packageFOOTNOTE:\url{http://wiki.ros.org/tug\_ist\_model\_based\_diagnosis}}

    - Specifying the model as a continuous dynamical system---practitioners form what is called the \textit{FDI} community

        - Diagnosis requires the construction of observers, which we call detectors in the previous section, for state tracking, parameter estimation, or the elimination of unknown variables in the system (see Fig.~\ref{fig:system-diagram} for a general idea). The detectors generate residuals that are sensitised to different faults to aid in fault isolation {% cite Isermann2011 Gertler2014 %}.
        - In robotics such a method is often used to detect hardware faults {% cite Crestani2015 Khalastchi2018 %}.
        - By default, the bulk of the effort in FDI focuses on the generation of meaningful residuals: the assumption being that meaningful residual signals make the isolation problem trivial. There is some work however that acknowledges the need for intelligent reasoning over the residuals {% cite Abreu2011 Reppa2016 %}.



- \textit{DX} diagnosis requires the specification of both the system model and the observations as logical fluents. Such an approach is powerful allowing for temporal diagnoses~{% cite Trave-Massuyes2007 %}, distributed diagnoses~{% cite Fabre2005 %}, and even counterfactual reasoning of fault causality {% cite Leitner-Fischer2013 Gossler2015 %}. However, specifying system behaviour as logical fluents can be time-consuming and brittle in the face of increased system complexity. Additionally, most DX approaches do not scale well with system complexity (admittedly this is an active area of research). Therefore, we do not extend such approaches.

- Among the \textit{FDI} approaches, {% cite Abreu2011 %} developed a method to isolate faults from among multiple active fault residuals (as mentioned earlier). The key problem examined by the authors is that of handling a combinatorial increase in the number of fault candidates when diagnosing \textit{Multiple Faults}. In the context of the mathematical definitions of our problem statement, the {% cite Abreu2011 %} model assumes a simple causal structure $S_t \rightarrow O_t$ with $S_t \independent S_{t+1}\; \text{and} \;O_t \independent O_{t+1},\; \forall t \in [0, T-1]$. The method of {% cite Abreu2011 %} then requires a database of rules (called a signature matrix) relating $O_t$ to $S_t$ in order to infer a general $P(S_t | O_t)$ for any given time $t$. We consider here other work that either augments the methods of {% cite Abreu2011 %} or makes different assumptions than the work:


    - \textit{In Robotics}: {% cite Abreu2011 %} is developed in the context of software debugging; their work has been applied for fault isolation in robotics by {% cite Khalastchi2018 %}. We focus on robotics applications too.

    - \textit{Distributed Isolation}: {% cite Chanthery2016 Reppa2016 %} address problems of fault isolation in a distributed setting. We do not tackle the problem of distributed fault isolation in this work.

    - \textit{Residual Selection}: The association rules identifying faults to residuals through the signature matrix need not be specified by humans; they can be generated directly from a system model or from the model of the detector itself. This can lead to many residuals with differing sensitivities to the same fault. {% cite Jung2018a %} approaches isolation as a residual selection problem of selecting those residuals that provide maximal discrimination to isolate any given fault. Our focus will not be on the problem of residual selection.

    - \textit{Residual Generation}: As mentioned before, most work in the FDI community focuses on generating meaningful residuals to make the isolation task trivial.

        - {% cite Meskin2010 %} provide theoretical results for Markov Jump Linear System (MJLS),FOOTNOTE:MJLS are systems consisting of multiple linear dynamical systems that can switch between each of the linear system modes over the course of execution.} especially describing conditions on the system when observers (detectors) generated for an MJLS can lead to trivial fault isolation.
        - {% cite Shi2015a Li2017 Rong2018 %} extend the results of {% cite Meskin2010 %} to domains where the underlying transition probabilities of the MJLS are unknown or uncertain.
        - {% cite Wu2016a %} formulate the problem of residual generation for MJLS as a convex optimization problem and successfully isolate faults in an underactuated robot arm.
        - {% cite Noshirvani2018 %} model a wind turbine as a dynamical system, use a UKF to estimate the turbine's states, and then cleverly design observers (detectors) to isolate faults in the turbine.

    We will not concern ourselves with the problem of optimal residual generation.

    - \textit{Temporal Faults}: The temporal nature of faults is sometimes crucial for the fault isolation process, with the duration of a fault or its order with respect to other faults being the desired output of the isolation process. Recursive state estimation processes, especially Particle Filters, are useful when given a model:

        - {% cite Verma2004 %} show that the use of particle filters for fault isolation over time is possible for NASA rovers. They also introduce extensions to the weighted sampling of particle filters to address rare and critical faults.
        - {% cite Yang2014 %} apply particle filters for fault isolation in aircraft auxiliary power units
        - {% cite Zhou2015 %} introduce another extension to the importance sampling for particle filters to track very rare faults in a monitored power generator.

    We do not assume access to a system model and hence do not use particle filters.

    - \textit{Automated Model Specification}: Specifying the system model for the purpose of generating residuals and isolating faults can be tedious. Some works extend knowledge-based methods to reduce the burden of fault model specification:

        - {% cite Ricks2014 %} introduce a system to take as input an electrical system diagram and produce a Bayes Net model of the system that can be used for fault isolation.
        - {% cite Birnbaum2015 %} introduce a system to take as input a UAV flight plan and then generate an expected behavioural model of the UAV through simulation. The model can then be used for fault detection and isolation.
        - {% cite Yu2017 %} extend the work of {% cite Baah2010 %} by creating a dependency graph of software by static analysis and then converting the graph into a Bayes Net with structure learning that is guided by information-theoretic metrics. The resulting Bayes Net can be used to localize faults.

    We will not tackle the problem of automated model specification.

    - \textit{Approximate Fault Models}: As an alternative to an execution or behavioural model of the system (the common model specified in the above works), the system model can be approximated as one that transitions between "fault states'', i.e. the system is modelled in the failure space~{% cite Pattipati1994 %}. Such an approach can sometimes better model faults arising from complex interactions between components in a large system {% cite Pattipati1994 zhang2017uncertainty %}:

        - {% cite Dong2007 %} approximate their system model as a Hidden Semi-Markov Model (HSMM) and use it to estimate the health of components. In their prognosis-oriented work (their goal is to perform condition-based monitoring), they argue that a generative model like the HSMM is necessary.
        - {% cite Nielsen2013 %} approximate the system and its dependencies as a Bayes Net, which can then be used to infer complex (but non-temporal) dependencies between component faults. {% cite Ricks2014 Yu2017 %}, mentioned earlier, also use a generated Bayes Net model for the same purpose.
        - {% cite Kodali2013a %} use factorial HMMs (see~{% cite ghahramani1996factorial %}) to model systems with time delays in how faults manifest in order to diagnose masked faults, and {% cite Kodali2013 %} use coupled HMMs (see~{% cite saul1999mixed %}) to diagnose faults in systems where there might be dependencies between the faults. {% cite Zhang2013 %} combines the results of {% cite Kodali2013a Kodali2013 %} into a coupled HMM model that aims to isolate faults in systems where faults influence each other through time delayed connections, and {% cite Zhang2018c %} provides methods to learn parameters of this final model from the data. {% cite Abdollahi2016 %} provides a survey of the work from this group, particularly explaining the graphical model that is used by them in all their prior efforts.FOOTNOTE:This group has strangely been quiet since their explosive year of 2013. The PI for this work is a cofounder of QSI~{% cite Pattipati1994 %}---a company that is (worryingly?) focused on fault diagnosis (\url{https://www.teamqsi.com/solutions/overview/}). As another aside: reading the survey paper~{% cite Abdollahi2016 %}, it is very hard not to think that every problem in fault diagnosis has been solved by 2013---the survey has no references in the Related Works that were published after 2013, and a ton of references for nearly all the problems mentioned in this document that date from 1970--2000.}
        - {% cite Zhang2016a zhang2017uncertainty %} approximate their system through an HMM and develop a novel parameter estimation technique for HMMs in order to better quantify the uncertainty in parameter estimates given training data. Their goal is to obtain better uncertainty characterization during fault isolation and system prognosis.

    When creating approximate fault models for the purposes of isolation, it is often necessary to deal with unknown faults. There has been some work on addressing this issue:

        - {% cite Smyth1994 %} trains both a discriminative HMMFOOTNOTE:Ignore the oxymoron here. It is a reference to the direction in which the observation probabilities of the HMM are modelled.} to isolate known faults and a generative HMM to model the probability distribution of residuals. He then classifies the system's state as a known fault or an unknown fault based on posterior probabilities on the data provided by both HMMs.
        - {% cite Lee2010 %} uses a multivariate process monitoring metric, the Holtelling multivariate control chart, to decide when to add an additional state to an HMM that models fault states.

    As mentioned earlier, we plan to use approximate fault models to isolate faults in our system. Specifically, we plan to expand upon {% cite Smyth1994 Dong2007 Zhang2013 Zhang2016a Zhang2018c %} in our problem formulation and solution.



A drawback of one-shot fault isolation, described until now, is that it does not mimic the methods of humans when diagnosing faults---humans tend to adopt an troubleshooting-approach to diagnosis where faults are isolated as a result of successive tests. The problem is sometimes called the Test Sequencing Problem and some of the works in this field are:

- {% cite Pattipati1990 %}, using the problem formulation described in {% cite Abdollahi2016 %}, approach the problem as an MDP solved by and AND-OR graph, where diagnoses are pruned on the basis of successive tests, each of which has an associated cost; the goal is to minimize the cost. {% cite Shakeri2000 %} extends the method to multiple faults by including recovery strategies, showing as part of the process that multiple iterations of single fault diagnosis is not as good. {% cite FangTu2003 %} adds information-theoretic heuristics to the search process, while {% cite Boumen2009 %} decomposes the troubleshooting problem into hierarchies of search-spaces.FOOTNOTE:{% cite Boumen2009 %} don't actually manage to minimize the cost but instead argue that the modelling effort is reduced; I'm unsure how they measure that.

- {% cite breese1996decision %} is an early work that uses Bayes Nets to model the system, and then use such a model to calculate the expected cost of diagnosis and repair actions during a troubleshooting episode. Their method can perform mutations to the Bayes Net as part of the troubleshooting; operations akin to a causal $do$ operation. The system was used in Windows 95 to diagnose various software errors. Note that the problem is never explicitly formulated as an MDP in this work.

- {% cite Bhattacharjya2007 %} is part of (what seems like) a disconnected school of thought that also models the Test Sequencing Problem as an MDP. The work presents an alternative, Decision Circuits, to classical asymmetrical decision problem representations in their field---Decision Trees and Influence Diagrams. In addition to allowing for efficient inference~\cite{Bhattacharjya2007,liu2015complexity}, Decision Circuits allow for sensitivity analysis of the solution test sequence~{% cite Bhattacharjya2008 %}.

- {% cite Chen2017 %} use a Value-of-Information metric to ask questions (tests) from humans when troubleshooting. Their contribution is to prune a possibly infinite space of tests and hypotheses that can arise in generic troubleshooting domains.FOOTNOTE:{% cite chen2017near %} is the first author's Ph.D. thesis on using metrics like the Value-of-Information for Adaptive Information Acquisition in multiple application domains.}

- {% cite javdani2014near %} is an earlier workFOOTNOTE:By Shervin Javdani from Sid Srinivasa's group.} on active selection of tests for decision making---the authors of {% cite Chen2017 %} are coauthors. The work formalizes the test selection problem as one of determining "decision-regions'' rather than the exact hypothesis; the problem is now known as a Decision Region Determination (DRD) problem. The work is applied to the problem of a robot, HERB, localizing a button on a surface through touch.

- {% cite nushi2017human %} tackle the problem of troubleshooting errors in component-based ML systems with a view towards improving the system.FOOTNOTE:I really like the following line in their motivation: "Human intervention is crucial to the approach as human fixes simulate improved component output that cannot be produced otherwise without significant system development efforts.''} Given a component-based model of a system, the authors devise a system to automatically garner human feedback from crowd-workers on system performance and subsystem performance. The system can then provide insights into improvements for aspects of the combined ML pipeline lead to the biggest gains in system performance. {% cite nushi2018towards %} explores methods for meaningfully presenting those insights to system designers.

- {% cite Qiu2016 %} use what seem to be a variant of Genetic Algorithms, called Differential Evolution Algorithms, to derive minimal cost test sequences in large problem domains. From the references, this approach seems to be popular in China.

- {% cite Tian2018a %} show that an iterative growing algorithm approach to the MDP of {% cite Pattipati1990 %} is a better approach than the rollout strategies suggested by {% cite FangTu2003 %}. Additionally, {% cite Tian2018 %} extend the isolation through test sequencing to domains where test outputs can be multi-valued and not just binary.

- {% cite Rodler2018 %} is a survey of common metrics used in local search heuristics for \textit{query selection}---a generalization of the \textit{test} in Test Sequencing that can also be applied to information gathering for constructing knowledge-bases. The paper compared heuristics for picking the next query, ranging from Information Gain (Entropy) to KL-divergence to Split-in-half, and found no conclusiveFOOTNOTE:Admittedly, it is very hard to parse the results.} difference. My biggest take-away from the paper was that probability-based heuristics, such as Entropy, are more sensitive to imperfect test results than non-probability-based heuristics, such as Split-in-half.

- {% cite Wei2017 %} tackle the problem of deriving a test sequence in domains where tests have precedence constraints and might be imperfect. Their solution involves tabu search coupled with importance sampling.

- In the realm of "Active Diagnosis'', {% cite Jung2018 %} use a system model to derive an expression using (relaxed) convex optimization for the sensitivity of faults to various system inputs. With such an expression, they then excite the system's inputs to assist in isolation. Although the method only performs one-shot isolation, I've included it as a potential means of autonomously determining actions to take during Test Sequencing.

It might perhaps behove us to approach the fault isolation problem as one of active diagnosis because it could also more easily feed into the ultimate arbitration problem that we're interested in.


## Part 2

In future factories, workers are more likely to fulfil the roles of troubleshooters and problem-solvers rather than their traditional roles~{% cite Wurhofer2018 %}. Additionally, in scenarios such as assistive care, an adequate ability of care-givers to troubleshoot and repair robots might be necessary in order to minimize risk to patients~{% cite Brady2011 %}. While training and education for humans, as proposed in \cite{Brady2011,Wurhofer2018}, is one solution to the problem, another solution is to facilitate the human's ability to diagnose and troubleshoot a problem. Unfortunately, general mechanisms to achieve that are not always available and can lead to frustration:

\item {% cite Lin1999 %} found that most human interactions with robots often consists solely of maintenance and troubleshooting. Additionally, when the human is forced to wait on the robot due to a lack of diagnostic knowledge, the experience can be frustrating.
\item {% cite Sauppe2015 %} found that even when collocated with the robot, operators and maintenance staff often lacked the context or knowledge necessary to resolve a problem. The inclusion of a diagnostic interface for robot errors was one of the most requested features.

In this work, we aim to develop algorithms for diagnosis and troubleshooting during Human-Robot Interaction that make robots more reliable and facilitate the repair tasks of their human counterparts.

The problem of troubleshooting appears in the literature under many pseudonyms---Test Sequencing problem, Optimal Decision Tree problem, Bayesian Experimental Design, Equivalence Class Determination problem, Decision Region Determination problem, Asymmetrical Decision problem, Active Diagnosis, Active Learning, Feature Selection, etc. etc. In all of the problems, the goal is to achieve performance measure (classification accuracy, isolation of a hypothesis, etc.) within a constrained budget (number of queries, cost of queries, etc.). In the following bullet points, we enumerate some of the prior work:


\item {% cite Pattipati1990 %} addresses the Test Sequencing problem---determining the full sequence of tests to run in order to achieve a goal within a constrained budget---by formulating the problem as an MDP where fault diagnoses are pruned based on successive tests with the goal of minimizing the cost of the tests. {% cite Pattipati1990 %} provides search in an AND-OR graph as a solution to the problem. {% cite Shakeri2000 %} then extends the method to situations of masked multiple faults by reasoning about repair actions that can be undertaken during the diagnosis process. {% cite FangTu2003 %} introduces information-theoretic heuristics to the search process and {% cite Boumen2009 %} explores methods of decomposing the troubleshooting problem into a hierarchy of subproblems in order to reduce problem modelling effort.

\item {% cite Bhattacharjya2007 %} models the Test Sequencing problem in the context of Asymmetrical Decision problems for medicine, where a doctor must select a sequence of tests before deciding on the treatment for a patient; the problem is also formulated as an MDP. While prior work has represented Asymmetrical Decision problems as either Decision Trees or Influence Diagrams, {% cite Bhattacharjya2007 %} introduces a Decision Circuit representation, which allows for efficient inference of test sequences~\cite{Bhattacharjya2007,liu2015complexity} and for a sensitivity analysis of the treatment decision to various modelling assumptions~{% cite Bhattacharjya2008 %}.

\item {% cite nushi2017human %} tackle the problem of troubleshooting errors in component-based ML systems with a view towards improving the system.FOOTNOTE:I really like the following line in their motivation: "Human intervention is crucial to the approach as human fixes simulate improved component output that cannot be produced otherwise without significant system development efforts.''} Given a component-based model of a system, the authors devise a system to automatically garner human feedback from crowd-workers on system performance and subsystem performance. The system can then provide insights into improvements for aspects of the combined ML pipeline lead to the biggest gains in system performance. {% cite nushi2018towards %} explores methods for meaningfully presenting those insights to system designers.

\item {% cite Qiu2016 %} use what seem to be a variant of Genetic Algorithms, called Differential Evolution Algorithms, to derive minimal cost test sequences in large problem domains. From the references, this approach seems to be popular in China.

\item {% cite Tian2018a %} show that an iterative growing algorithm approach to the MDP of {% cite Pattipati1990 %} is a better approach than the rollout strategies suggested by {% cite FangTu2003 %}. Additionally, {% cite Tian2018 %} (same authors as {% cite Tian2018a %}) extend the isolation methods of {% cite Tian2018a %} to domains where test outputs can be multi-valued and not just binary.

\item {% cite Rodler2018 %} is a survey of common metrics used in local search heuristics for Query Selection---a generalization of the \textit{test} in Test Sequencing that can also be applied to information gathering when constructing knowledge-bases. The paper compared heuristics for picking the next query, ranging from Information Gain (Entropy) to KL-divergence to Split-in-half, and found no conclusiveFOOTNOTE:Admittedly, it is very hard to parse the results.} difference. The biggest take-away from the paper was that probability-based heuristics, such as Entropy, are more sensitive to imperfect test results than non-probability-based heuristics, such as Split-in-half.

\item {% cite Wei2017 %} tackle the problem of deriving a test sequence within domains where tests have precedence constraints and might be imperfect. Their solution involves tabu search coupled with importance sampling.

\item {% cite Jung2018 %} use a system model to derive an expression using (relaxed) convex optimization for the sensitivity of faults to various system inputs. With such an expression, they then excite the system's inputs to assist in isolation. The isolation method is one-shot; the goal in the work is to autonomously determine actions to take during diagnosis.

\item {% cite breese1996decision %} is an early work that uses Bayes Nets to model the system, and then use such a model to calculate the expected cost of diagnosis or repair actions during a troubleshooting episode. Their method can perform mutations to the Bayes Net as part of the troubleshooting; operations akin to a causal $do$ operation (see {% cite pearl2009causality %}). The system was used in Windows 95 to diagnose software errors.

\item {% cite Zheng2005 %} used a common Bayes Net structure to fault diagnoses---a bipartite graph of unobserved fault states connected to observable tests. Assuming knowledge of the conditional probabilities in such a structure, {% cite Zheng2005 %} provide (1) a loopy belief propagation mechanism for inferring the probability of multiple fault situations using incremental observations, and (2) a mechanism for selecting the next observation using the conditional entropy of the hidden states (the hypothesis space).

\item Selecting the next test based on metrics calculated over a desired hypothesis space is a generalization of all of the above approaches; the domain is called Bayesian Active Learning.FOOTNOTE:There are lots of references for this and other related terms. Not including them here.} Particularly, if the metric in question is \textit{adaptive monotone} and \textit{adaptive submodular},FOOTNOTE:The value of the metric is always increasing or decreasing, and successive tests provide diminishing returns.} then look-ahead search based on an MDP formulation (say) is unnecessary because a greedy policy of selecting queries based on maximizing (or minimizing) the metric is near-optimal~{% cite golovin2010near Bellala2012 javdani2014near %}. Such a condition is true in many domains and in fact, many of the previous works implicitly take advantage of this property without realizing it. We next explore some works in Bayesian Active Learning:

    \item {% cite golovin2010near %} is one of the first works to prove the near-optimality of a greedy algorithm for cases when the monotonic and submodularity conditions are satisfied. In addition, they define a related problem to that of isolating a single hypothesis: that of isolating a class of hypotheses, called the Equivalence Class Determination (ECD) problem. The reformulation to classes of hypotheses proves to be crucial for dealing with noisy tests where noisy test results might isolate a hypothesis in the neighbourhood of the true hypothesis. In order to solve the reformulated problem efficiently, the authors employ a graph-cut-like approach.

    \item {% cite Bellala2012 %}, almost concurrently to {% cite golovin2010near %}, provide another proof of the optimality of a greedy algorithm. However, they have other very interesting (to us) results of the problem:

        \item In the case of vanilla active learning---isolating a single hypothesis using single queries---the most widely used algorithm of Generalized Binary Search, similar to decision tree learning, uses entropy to choose the most balanced splits.
        \item When isolating groups of hypotheses, a bias term in the tree learning metric is necessary to ensure that leaves of the tree contain at most one group of hypotheses. The na\"ive augmentation of the entropy metric is not adaptive submodular, so the paper presents a modified metric based on weighted approximate Gini indicesFOOTNOTE:As far as I understand, the Gini index is an approximation of inequality in the probability masses on the left and right.} that is adaptive submodular.
        \item \label{pt:group-query-intro} The paper is situated in the domain of guiding a human to ask questions during a chemical spill diagnosis, so the authors posit that during the process, \textit{humans would rather pick between groups of queries rather than be forced to use a single query}. The results of the paper show that reasoning about groups of queries for selection (instead of a single query) is possible and that there is only a minimal increase in the total number of queries.
        \item Similar to {% cite golovin2010near %}, the authors liken the problem of diagnosing in the face of query noise to that of diagnosing a group of similar hypotheses (the ECD problem). In order to avoid a costly enumeration of all possible noisy hypotheses related to a given hypothesis, the authors provide an algorithm using "combinatorics approximation'' techniques.FOOTNOTE:I made up the term. Also I suspect that the runtime of {% cite golovin2010near %} is better.}

    Most interestingly, and surprisingly, point \ref{pt:group-query-intro} seems to never have been verified or validated in another work, and especially not in the realm of fault diagnosis.

    \item {% cite Bellala2013 %} is an interesting departure from prior work in that it suggests using (the estimate of) AUC (area under the curve) of ranked diagnoses when deciding the next query; instead of a traditional entropy measure. Their justifications are:

        \item A domain expert is better suited to selecting the top-K diagnoses given knowledge of the situation, so it is better to present them with a ranking, and therefore query selection should optimize for that.
        \item By presenting a ranking, we can design an algorithm for single fault diagnosis but apply it in a multiple fault setting simply by changing the threshold for accepting fault hypotheses in a ranked list. Assuming a single fault condition during algorithm design also precludes the need for computationally intensive belief propagation.
        \item Using AUC instead of entropy is more robust to (a) the assumption above of applying single fault diagnosis in the multiple fault case, and (b) the estimate of noise parameters if the query outputs are noisy.

    There are numerous natural follow-ons to the work, that I am surprised do not seem to exist:

        \item The assumption of a ranked list as being preferred for the human has not been validated, especially in an active diagnosis context.
        \item By considering AUC rather than entropy, the algorithm allows for the use of \textit{any} (well calibrated) ML algorithm for classifying the fault given query results. There doesn't seem to be work exploring this.FOOTNOTE:I imagine the realm of Feature Selection probably has analogous work, but I've been steering clear of it mostly for the sake of my sanity.}


    \item {% cite javdani2014near %} extends the work of {% cite golovin2010near %} by focusing on grouping hypotheses in an ECD problem according to the decisions they entail---a problem called the Decision Region Determination (DRD) problem. When focusing on decision regions, hypothesis classes often overlap, and {% cite javdani2014near %} refute the assumption that "group identification with overlapping groups is reducible to that of disjoint groups arising out of the partition of the overlapping regions'' (as stated in {% cite Bellala2012 %}). Therefore, to solve the DRD problem, {% cite javdani2014near %} create a query selection metric based on graph-cuts in hypergraphs, a method that preserves the monotonicity and submodularity of the selection metric. The reformulated problem is then used successfully by a robot, HERB, to localize a button on a surface solely through touch.

    \item {% cite chen2015value %} introduces the problem of selecting queries based on a metric of "Decision Robustness'' as opposed to merely entropy. In a manner similar to that of {% cite Bellala2013 %}, the authors argue that in applications where a decision-maker must reduce their liability to unknown information in the future, a metric that minimizes the sensitivity of the decision to new informationFOOTNOTE:The metric is termed Expected Same Decision Probability (E-SDP) in the work.} is the most preferred. {% cite choi2017optimal %} then introduces a method called Sentential Decision Diagrams to efficiently determine successive queries through E-SDP.

    \item {% cite holladay2016active %} uses the work of {% cite golovin2010near javdani2014near %} to learn user preferences from pairwise comparison queries. A similar approach is used by {% cite Wilde2019 %} to both learn user preferences when constructing a task model from pairwise comparison queries, and also to decide the next query to present for a pairwise comparison test.FOOTNOTE:The approach of learning preferences from pairwise comparisons is a burgeoning field. I do not yet know how relevant these approaches are to the problem at hand.}

    \item \cite{SzeZhengYong2017,Yong2018} extend the theoretical proofs of \cite{golovin2010near,javdani2014near} and apply their algorithms to the problem of active state estimation in the presence of faults.FOOTNOTE:A sort of dual to the problem of fault estimation in the presence of all states, which is what we're interested in.}

    \item {% cite Pu2017 %} is an interesting project that tries to avoid modelling the hypothesis space for Bayesian Active Learning, and simply attempts to infer an informative query given correlations between observations (think of the game of Battleship).


\item The above work in Active Learning does not necessarily assume that tests or queries are answered by humans (the exceptions should be apparent). However, in situations where it is true that queries are answered by humans, it becomes necessary to constrain queries to forms that humans expect or understand.

    \item {% cite Cakmak2012 %} introduce the concept of \textit{label}, \textit{demo}, and \textit{feature} queries when soliciting information from users. Broadly, the three types of queries are:

        \item \textit{Label}: A closed-form question expecting a single response about an unlabeled input; usually "yes/no'', but sometimes a specific label.
        \item \textit{Demo}: An open question in a constrained situation with minimal expectations on the form of the response.
        \item \textit{Feature}: Assuming features known to the robot that are semantically interpretable by the human, a feature query is a question requesting the reasons (the causes) for a response. Depending on the form of the query, the response can be "yes/no'' or more open-ended.


    \item {% cite Bullard2018 %} examine a method of choosing between the different types of queries for a classification task. In doing so, they also reason about \textit{when} a particular query should be used in addition to deciding on the type of query. Prior work by the same authors, {% cite Bullard2018a %}, shows that in the event of interpretable features, humans are capable of selecting the most informative features for classification; even outperforming computational feature selection approaches.



Based on the prior work, it appears that the biggest gaps in the troubleshooting literature are:

\item There appears to have been no evaluation of the types of troubleshooting queries that should be used. Instead of ranks and groups, as suggested in \cite{Bellala2012,Bellala2013}, one can consider the types of troubleshooting queries that are presented to the human conform to demo/label/feature-subset queries~\cite{Cakmak2012,Bullard2018}.

\item The distinction between the look-ahead MDP search and the greedy submodular search, as well as the simplicity of the argument of using AUC instead of entropy made by {% cite Bellala2013 %}, suggests that there might be other metrics or techniques worth exploring for the query selection problem. Kalesha has suggested that I peruse {% cite Settles2012 %}.FOOTNOTE:Another paper (book) that I will get to when I have the will to read.}

\item In the troubleshooting scenario, some tests might require the robot to take physical action, such as move its head or its base. None of the works explicitly exploits such a capability.FOOTNOTE:Note that such an approach would be both an application of Human-guided Active Learning and of Active Perception, which I am told is also a novel contribution.}

\item Along the lines of the previous point, part of the troubleshooting process involves repairing components and then checking whether something else is wrong. As far as I know, \cite{breese1996decision,Shakeri2000} are among the few works that explicitly consider this possibility.



## References

{% bibliography --cited_in_order %}
