import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://kolloch.github.io',
	base: '/astro-starlight-with-nix',
	integrations: [
		starlight({
			title: 'Astro Starlight with Nix',
			social: {
				github: 'https://github.com/kolloch/astro-starlight-with-nix',
			},
			sidebar: [
				{
					label: 'Guides',
					items: [
						// Each item here is one entry in the navigation menu.
						{ label: 'Example Guide', link: '/guides/example/' },
					],
				},
				{
					label: 'Reference',
					autogenerate: { directory: 'reference' },
				},
			],
		}),
	],
});
