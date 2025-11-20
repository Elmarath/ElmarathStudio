import { PERSONAL_INFO } from '../constants';

// Document list for HomepageDocumentPreviews component
export const DOCUMENT_LIST = [
  {
    title: "Local Staged Interaction",
    Img: require('@site/static/img/T_LSI_LocalStagedInteractionThumbanil.png').default,
    description: "Local Interaction System that uses stages as a way to create complex player interactions with ease.",
    DocLink: 'docs/Local-Staged-Interaction/AboutLocalStagedInteraction',
    FabLink: 'https://www.unrealengine.com/marketplace/en-US/product/local-staged-interaction',
  },
  {
    id: 'EasyTraceTrailSystem',
    title: "Easy Trace-Trail System",
    Img: require('@site/static/img/T_EasyTraceTrailSystemThumbnail.png').default,
    description: "A modular, optimized solution for easily controlling and extending hit results from continuous hit trails.",
    DocLink: '/docs/Easy-Trace-Trail-System/EasyTraceTrailSystem',
    FabLink: 'https://www.unrealengine.com/marketplace/en-US/product/advanced-hit-trailer',
  },
  {
    title: "Ability Queue Task System",
    Img: require('@site/static/img/T_AbilityQueueTaskSystemThumbnail.png').default,
    description: "Extension of Epic's Gameplay Ability System. Enables queueable abilities with priority-based activation.",
    DocLink: '/docs/Ability-Queue-Task-System/Startup',
    FabLink: 'https://www.unrealengine.com/marketplace/en-US/product/ability-queue-system',
  },
  {
    title: "Nested Inventory Architecture",
    Img: require('@site/static/img/T_NIA_Thumbnail.png').default,
    description: "Create customizable, nested, section-based, object-oriented inventory systems for intuitive gameplay.",
    DocLink: '/docs/Nested-Invnetory-Architecture/AboutNestedInventoryArchitecture',
    FabLink: 'https://www.unrealengine.com/marketplace/en-US/product/nested-inventory-architecture',
  },
  {
    title: "Modular Action System",
    Img: require('@site/static/img/T_ModularActionSystemLogo.png').default,
    description: "A modular, data-driven action system for games. Network-ready and easy to customize.",
    DocLink: '/docs/Modular-Action-System/About-Modular-Action-System',
    FabLink: 'https://www.unrealengine.com/marketplace/en-US/product/modular-action-system',
  },
  {
    title: "Easy Skeletal Mesh Merge Async",
    Img: require('@site/static/img/EasySkeletalMeshMergeAsync.png').default,
    description: "A simple and optimized workflow to create modular characters via skele merging.",
    DocLink: '/docs/category/easy-skeletal-mesh-merge-async',
    FabLink: 'https://www.unrealengine.com/marketplace/en-US/product/easy-skeletal-mesh-merge-async',
    GitHubLink: 'https://github.com/Elmarath/EasySkeletalMeshMergeAsync',
  },
  {
    title: "Easy Ability Set System",
    Img: require('@site/static/img/T_EasyAbilitySetSystem_Logo.png').default,
    description: "Ability Set Management System that handles both granting and input binding for Gameplay Ability System.",
    DocLink: '/docs/Easy-Ability-Set-System/EasyAbilitySetSystemStartup',
    FabLink: 'https://www.unrealengine.com/marketplace/en-US/product/easy-ability-set-system',
  },
  {
    title: "Dynamic Input System",
    Img: require('@site/static/img/T_DynamicInputSystemThumbanil.png').default,
    description: "A flexible, runtime input management system that allows dynamic binding and modification of input mappings during gameplay.",
    DocLink: '/docs/Dynamic-Input-System/DynamicInputSystem',
    GitHubLink: 'https://github.com/Elmarath/DynamicInputSystem',
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