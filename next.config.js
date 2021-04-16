module.exports = {
    future: {
        webpack5: true,
    },
    generateBuildId: async () => {
        // In an effort to make builds reproducible.
        return 'static'
    },
    optimization: {
        moduleIds: 'deterministic',
    }
}
