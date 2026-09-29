export default function portfolioHomeDataPlugin() {
  return {
    name: 'portfolio-home-data',
    allContentLoaded({allContent, actions}) {
      const portfolioContent =
        allContent['docusaurus-plugin-content-blog']?.portfolio;

      if (!portfolioContent || !Array.isArray(portfolioContent.blogPosts)) {
        throw new Error('Portfolio blog content is unavailable.');
      }

      const projects = portfolioContent.blogPosts
        .filter(({metadata}) => !metadata.unlisted)
        .map(({metadata}) => ({
          permalink: metadata.permalink,
          title: metadata.title,
          description: metadata.description,
          date: metadata.date,
          tags: metadata.tags.map(({label, permalink}) => ({label, permalink})),
          frontMatter: {image: metadata.frontMatter.image},
        }));

      actions.setGlobalData({projects});
    },
  };
}
