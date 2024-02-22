import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://kolloch.github.io',
	base: '/n2c-mod',
	integrations: [
		starlight({
			title: 'n2c-mod',
			description: 'A flake module for nix2container.',
			social: {
				github: 'https://github.com/kolloch/n2c-mod',
			},
			editLink: {
				baseUrl: 'https://github.com/kolloch/n2c-mod/edit/master/docs/',
			},
			sidebar: [
				{
					label: 'Guides',
					autogenerate: { directory: 'guides' },
				},
				{
					label: 'Reference',
					autogenerate: { directory: 'reference' },
				},
			],
		}),
	],
});
