// Stats for Challenge Variation

{
	spriteContent: self.getResource().getContent("desertbusstage"),
	animationId: "challenge",
	ambientColor: 0x55ea9b23,
	shadowLayers: [
		{
			id: "0",
			maskSpriteContent: self.getResource().getContent("desertbusstage"),
			maskAnimationId: "shadowMaskFront",
			color:0x40000000,
			foreground: true
		},
		{
			id: "1",
			maskSpriteContent: self.getResource().getContent("desertbusstage"),
			maskAnimationId: "shadowMask",
			color:0x40000000,
			foreground: false
		}
	],
	camera: {
		startX : 0,
		startY : 43,
		zoomX : 0,
		zoomY : 0,
		camEaseRate : 1 / 11,
		camZoomRate : 1 / 15,
		minZoomHeight : 416,
		initialHeight: 416,
		initialWidth: 740,
		backgrounds: [
			// Sky
			{
				spriteContent: self.getResource().getContent("desertbusstage"),
				animationId: "emptyanim",
				mode: ParallaxMode.BOUNDS,
				originalBGWidth: 768,
				originalBGHeight: 432,
				horizontalScroll: false,
				verticalScroll: false,
				loopWidth: 0,
				loopHeight: 0,
				xPanMultiplier: 0.06,
				yPanMultiplier: 0.06,
				scaleMultiplier: 1,
				foreground: false,
				depth: 2001
			}
		]
	}
}
