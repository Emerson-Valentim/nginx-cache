const path = require("path");

module.exports = {
  entry: "./src/index.js",
  output: {
    libraryTarget: "commonjs",
    filename: "main.js",
    path: path.resolve(__dirname, "dist"),
  },
  target: "node",
  optimization: {
    minimize: false,
  },
  resolve: {
    modules: ["node_modules"],
    extensions: [".ts", ".js"],
  }
};
