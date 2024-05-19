const express = require('express');
const Generator = require('@asyncapi/generator');
const fs = require('fs');
const path = require('path');

const router = express.Router();
const asyncApiDocumentPath = path.join(__dirname, '../asyncapi.yaml');
const outputDir = path.join(__dirname, '../generated-docs');

async function generateAsyncApiDocs() {
    const generator = new Generator('@asyncapi/html-template', outputDir, {
        forceWrite: true,
        templateParams: {},
    });

    await generator.generateFromFile(asyncApiDocumentPath);
}

generateAsyncApiDocs().then(() => {
    console.log('AsyncAPI document has been converted to HTML');
}).catch(error => {
    console.error('Error generating AsyncAPI documentation:', error);
});

router.get('/', (req, res) => {
    const indexPath = path.join(outputDir, 'index.html');
    if (fs.existsSync(indexPath)) {
        res.sendFile(indexPath);
    } else {
        res.status(404).send('AsyncAPI documentation not found');
    }
});

module.exports = router;
