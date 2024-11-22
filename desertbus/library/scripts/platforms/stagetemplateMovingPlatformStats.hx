// Animation stats for Assist Template Projectile

{
    spriteContent: self.getResource().getContent("desertbusstage"),
    initialState: PState.ACTIVE,
    stateTransitionMapOverrides: [
        PState.ACTIVE => {
            animation: "endcutscene"
        }
    ],
    gravity: 0
}