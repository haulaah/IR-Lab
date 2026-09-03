
# Incident Response Lab

A simulated incident response (IR) exercise for a research study: participants are trained,
then respond to the same simulated security incident.

The lab is built from four open-source tools: **TheHive**, **Cortex**, **MISP**, and
**Mattermost** and run with Docker.
See [`ir-lab-docker/`](./ir-lab-docker/) to deploy it.

## Research

The tools record responder activities. Our log-extraction tool collects these logs and turns
them into a dataset. That dataset feeds our *Semantic Log Aggregation Tool and Machine-Readable
Knowledge Base* prototype, producing a knowledge graph for IR process activities and communication data analysis.

**Publications**

- [Semantic Log Aggregation for a Machine-Readable Knowledge Base of Incident Response Activities](https://ieeexplore.ieee.org/abstract/document/11384833)  H. S. Galadima, C. Doherty, R. Brennan. *IEEE Cyber-RCI*, 2025.
- [Graph Analysis of Incident Response Process Activities and Communications](https://link.springer.com/chapter/10.1007/978-3-032-35579-9_22)  H. S. Galadima, C. Doherty, R. Brennan. *ARES (GRASEC)*, 2026.

## Cyber Defender: Incident Response Lab

<p align="center">
  <img src="./logo.png" alt="Incident Response Lab" width="600">
</p>

Exhibited at the **CyberWise** event for school children, where our stand gave students hands-on
access to an IR tool and guided them through tasks as simulated defenders of an organisation under
attack and entering findings on a tablet website while a live tool environment and step by step
posters supported them. https://haulaah.github.io/IR-Lab/
