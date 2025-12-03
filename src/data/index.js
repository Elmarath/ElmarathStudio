import { PERSONAL_INFO } from '../constants';

// Document list for HomepageDocumentPreviews component
export const DOCUMENT_LIST = [
  {
    id: 'StagedInteractionSystem',
    title: "Staged Interaction System",
    Img: require('@site/static/img/T_StagedInteractionThumbnail.png').default,
    description: "Staged Interaction System that uses stages as a way to create complex player interactions with ease.",
    DocLink: 'docs/Staged-Interaction-System/Overview',
    FabLink: 'https://www.fab.com/listings/ea6cda8e-25b1-434e-a9ab-1c2bbaa5fe67',
  },
  {
    id: 'EasyTraceTrailSystem',
    title: "Easy Trace-Trail System",
    Img: require('@site/static/img/T_EasyTraceTrailSystemThumbnail.png').default,
    description: "A modular, optimized solution for easily controlling and extending hit results from continuous hit trails.",
    DocLink: '/docs/Easy-Trace-Trail-System/EasyTraceTrailSystem',
    FabLink: 'https://www.fab.com/listings/86d9af14-9ab3-4c47-83b2-96eb6a4b5957',
  },
  {
    title: "Ability Queue Task System",
    Img: require('@site/static/img/T_AbilityQueueTaskSystemThumbnail.png').default,
    description: "Extension of Epic's Gameplay Ability System. Enables queueable abilities with priority-based activation.",
    DocLink: '/docs/Ability-Queue-Task-System/Overview',
    FabLink: 'https://www.fab.com/listings/554398ff-338b-43da-bf43-b081ef166b92',
  },
  {
    title: "Nested Inventory Architecture",
    Img: require('@site/static/img/T_NIA_Thumbnail.png').default,
    description: "Create customizable, nested, section-based, object-oriented inventory systems for intuitive gameplay.",
    DocLink: '/docs/Nested-Invnetory-Architecture/AboutNestedInventoryArchitecture',
    FabLink: 'https://www.fab.com/listings/320f157f-9241-47ee-9f32-63aaf744f509',
  },
  {
    title: "Modular Action System",
    Img: require('@site/static/img/T_ModularActionSystemLogo.png').default,
    description: "A modular, data-driven action system for games. Network-ready and easy to customize.",
    DocLink: '/docs/Modular-Action-System/About-Modular-Action-System',
    FabLink: 'https://www.fab.com/listings/6ef3ecaa-1a2f-4056-a209-cf228df40c3f',
  },
  {
    title: "Easy Skeletal Mesh Merge Async",
    Img: require('@site/static/img/EasySkeletalMeshMergeAsync.png').default,
    description: "A simple and optimized workflow to create modular characters via skele merging.",
    DocLink: '/docs/Easy-Skeletal-Mesh-Merge-Async/EasySkeletalMeshMergeAsync',
    FabLink: 'https://www.fab.com/listings/616906a0-c73d-4e7a-9002-866a6d9751d5',
    GitHubLink: 'https://github.com/Elmarath/EasySkeletalMeshMergeAsync',
  },
  {
    title: "Easy Ability Set System",
    Img: require('@site/static/img/T_EasyAbilitySetSystem_Logo.png').default,
    description: "Ability Set Management System that handles both granting and input binding for Gameplay Ability System.",
    DocLink: '/docs/Easy-Ability-Set-System/EasyAbilitySetSystemStartup',
    FabLink: 'https://www.fab.com/sellers/Elmarath',
  },
  {
    title: "Dynamic Input System",
    Img: require('@site/static/img/T_DynamicInputSystemThumbanil.png').default,
    description: "A flexible, runtime input management system that allows dynamic binding and modification of input mappings during gameplay.",
    DocLink: '/docs/Dynamic-Input-System/DynamicInputSystem',
    GitHubLink: 'https://www.fab.com/listings/cdf2ad8e-b9b7-4b4e-87bb-fdcfbe3c3b2b',
    FabLink: 'https://www.fab.com/listings/cdf2ad8e-b9b7-4b4e-87bb-fdcfbe3c3b2b',
  }
];

// Contact items for PortfolioBox ContactModal
export const CONTACT_ITEMS = [
  {
    id: 'email',
    label: 'Email',
    value: PERSONAL_INFO.email,
    link: `mailto:${PERSONAL_INFO.email}`,
    icon: 'mail',
    action: 'link'
  },
  {
    id: 'resume',
    label: 'Resume/CV',
    value: 'View my professional CV',
    link: PERSONAL_INFO.resumeUrl,
    icon: 'resume',
    action: 'external'
  },
  {
    id: 'linkedin',
    label: 'LinkedIn',
    value: 'Connect with me on LinkedIn',
    link: PERSONAL_INFO.linkedinUrl,
    icon: 'linkedin',
    action: 'external'
  },
  {
    id: 'github',
    label: 'GitHub Profile',
    value: 'View all my projects',
    link: PERSONAL_INFO.githubUrl,
    icon: 'github',
    action: 'external'
  },
  {
    id: 'blog',
    label: 'About Me Blog',
    value: 'Read my personal story and journey',
    link: PERSONAL_INFO.blogPath,
    icon: 'blog',
    action: 'navigate'
  }
];